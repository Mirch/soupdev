use std::str::FromStr;

use aws_sdk_dynamodb::{Client, model::AttributeValue};
use lambda_http::{Error, IntoResponse, Request, Response};
use lambda_layer::{environment::get_env_variable, payment::{Payment, PaymentStatus}, request_utils::get_query_string_parameter};
use stripe::{Expandable::*, PaymentIntentId};
use uuid::Uuid;

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {

    let donation = match get_query_string_parameter(&event, "donation").parse::<i64>() {
        Ok(n) => n,
        Err(_err) => panic!("Wrong value.")
    };
    let to = get_query_string_parameter(&event, "to");

    let domain = format!("http://{}", get_env_variable("DOMAIN"));
    let secret_key = "sk_test_HmtYQSWjVu1dHEb4CvXxkmBc00MEphxieW";
    let client = stripe::Client::new(secret_key);

    let cancel_url = format!("{}/payment/cancel", domain);
    let success_url = format!("{}/payment/success", domain);
    let mut params = stripe::CreateCheckoutSession::new(cancel_url.as_str(), success_url.as_str());
    params.line_items = Some(Box::new(vec![stripe::CreateCheckoutSessionLineItems {
        price_data: Some(Box::new(stripe::CreateCheckoutSessionLineItemsPriceData {
            currency: stripe::Currency::USD,
            product_data: Some(Box::new(
                stripe::CreateCheckoutSessionLineItemsPriceDataProductData {
                    name: format!("Donation towards {}", to),
                    description: Option::None,
                    images: Option::None,
                    metadata: Default::default(),
                    tax_code: Option::None,
                },
            )),
            unit_amount: Some(Box::new(donation)),
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

    let mut intent_id = PaymentIntentId::from_str("").unwrap();
    match session.payment_intent {
        Some(value) => match *value {
            Id(id) => intent_id = id,
            _ => (),
        },
        None => panic!("No payment intent found."),
    };
    let intent_id = String::from(intent_id.as_str());

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let table_name = get_env_variable("PAYMENTS_TABLE_NAME");

    let request = client
        .put_item()
        .table_name(table_name)
        .item("id", AttributeValue::S(Uuid::new_v4().to_string()))
        .item("from", AttributeValue::S(String::new()))
        .item("to", AttributeValue::S(to))
        .item("amount", AttributeValue::N(donation.to_string()))
        .item("order_id", AttributeValue::S(intent_id))
        .item("status", AttributeValue::S((PaymentStatus::Pending as i32).to_string()));

    let _result = match request.send().await {
        Ok(_value) => println!("Item added successfully!"),
        Err(_error) => panic!("Could not add item!")
    };

    let url = session.url.unwrap();
    let response = Response::builder()
        .status(303)
        .header("Location", *url)
        .body(())
        .expect("Failed to get redirect url.");

    Ok(response)
}
