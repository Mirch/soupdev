use std::str::FromStr;

use aws_sdk_dynamodb::{model::AttributeValue, Client};
use chrono::Utc;
use lambda_http::{Error, IntoResponse, Request, Response};
use lambda_layer::{
    environment::{get_env_variable, DOMAIN, PAYMENTS_TABLE_NAME},
    payment::{PaymentStatus, PaymentRequestDTO},
    request_utils::{get_body},
};
use stripe::{Expandable::*, PaymentIntentId};
use uuid::Uuid;

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {

    let mut body: PaymentRequestDTO = match get_body(&event) {
        Ok(value) => value,
        Err(error) => panic!("Could not get the request body: {}", error)
    };
    body.amount *= 100;

    let domain = format!("http://{}", get_env_variable(DOMAIN));
    let secret_key = "sk_test_HmtYQSWjVu1dHEb4CvXxkmBc00MEphxieW";
    let client = stripe::Client::new(secret_key);

    let cancel_url = format!("{}/profile/{}", domain, body.to);
    let success_url = format!("{}/profile/{}", domain, body.to);
    let mut params = stripe::CreateCheckoutSession::new(cancel_url.as_str(), success_url.as_str());
    params.line_items = Some(Box::new(vec![stripe::CreateCheckoutSessionLineItems {
        price_data: Some(Box::new(stripe::CreateCheckoutSessionLineItemsPriceData {
            currency: stripe::Currency::USD,
            product_data: Some(Box::new(
                stripe::CreateCheckoutSessionLineItemsPriceDataProductData {
                    name: format!("Donation towards {}", body.to),
                    description: Option::None,
                    images: Option::None,
                    metadata: Default::default(),
                    tax_code: Option::None,
                },
            )),
            unit_amount: Some(Box::new(body.amount.into())),
            product: Option::None,
            recurring: Option::None,
            tax_behavior: Option::None,
            unit_amount_decimal: Option::None,
        })),
        quantity: Some(Box::new(1)),
        adjustable_quantity: Option::None,
        description: Option::None,
        dynamic_tax_rates: Option::None,
        price: Option::None,
        tax_rates: Option::None,
    }]));
    params.mode = Some(stripe::CheckoutSessionMode::Payment);

    let session = stripe::CheckoutSession::create(&client, params)
        .await
        .unwrap();

    let mut intent_id = PaymentIntentId::from_str("pi_test").unwrap();
    match session.payment_intent {
        Some(value) => if let Id(id) = *value { intent_id = id },
        None => panic!("No payment intent found."),
    };
    let intent_id = String::from(intent_id.as_str());

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let table_name = get_env_variable(PAYMENTS_TABLE_NAME);

    let request = client
        .put_item()
        .table_name(table_name)
        .item("id", AttributeValue::S(Uuid::new_v4().to_string()))
        .item("from", AttributeValue::S(body.from))
        .item("to", AttributeValue::S(body.to))
        .item("amount", AttributeValue::N(body.amount.to_string()))
        .item("order_id", AttributeValue::S(intent_id))
        .item("created", AttributeValue::S(Utc::now().to_string()))
        .item(
            "status",
            AttributeValue::N((PaymentStatus::Pending as i32).to_string()),
        );

    let _result = match request.send().await {
        Ok(_value) => println!("Item added successfully!"),
        Err(error) => panic!("{:?}", error),
    };

    let url = session.url.unwrap();
    let response = Response::builder()
        .status(303)
        .header("Location", *url)
        .body(())
        .expect("Failed to get redirect url.");

    Ok(response)
}
