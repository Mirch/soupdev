use std::str::FromStr;

use aws_sdk_dynamodb::model::AttributeValue;
use aws_sdk_dynamodb::model::Select;
use aws_sdk_dynamodb::Client;
use lambda_http::Response;
use lambda_http::{Error, IntoResponse, Request};
use lambda_layer::environment::get_env_variable;
use lambda_layer::payment::PaymentStatus;
use lambda_layer::request_utils::get_body_as_json_string;
use lambda_layer::request_utils::get_header_value;
use stripe::EventObject;
use stripe::PaymentIntentId;

const SIGNATURE_KEY: &str = "Stripe-Signature";
const SECRET_KEY: &str = "STRIPE_WEBHOOK_SECRET";

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    let order_id_index = get_env_variable("ORDER_ID_INDEX");
    
    let signature = get_header_value(&event, SIGNATURE_KEY);
    let secret = get_env_variable(SECRET_KEY);
    let payload = get_body_as_json_string(&event);

    let webhook_event = match stripe::Webhook::construct_event(&payload, &signature, &secret) {
        Ok(result) => result,
        Err(err) => panic!("{}", err),
    };

    let mut intent_id = PaymentIntentId::from_str("pi_").unwrap(); // placeholder payment intent
    match webhook_event.data.object {
        EventObject::Charge(value) => {
            let expandable_intent = *(value.payment_intent.unwrap());

            match expandable_intent {
                stripe::Expandable::Id(id) => intent_id = id,
                _ => ()
            };
        },
        _ => (),
    };

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let table_name = get_env_variable("PAYMENTS_TABLE_NAME");

    let query = client
        .query()
        .table_name(&table_name)
        .index_name(order_id_index)
        .key_condition_expression("#key = :value".to_string())
        .expression_attribute_names("#key".to_string(), "order_id")
        .expression_attribute_values(
            ":value".to_string(),
            AttributeValue::S(intent_id.to_string()),
        )
        .select(Select::AllAttributes);

    println!("Query: {:?}", query);

    let response = match query.send().await {
        Ok(response) => response,
        Err(_error) => panic!("Could not find entry with order id {}.", intent_id),
    };
    let payment = response.items().unwrap().first().unwrap();
    let payment_id = payment.get("id").unwrap().to_owned();

    let update = client
        .update_item()
        .table_name(&table_name)
        .key("id", payment_id)
        .update_expression("SET status=:s")
        .expression_attribute_values(
            "s".to_string(),
            AttributeValue::S((PaymentStatus::Paid as i32).to_string()),
        );

    let result = match update.send().await {
        Ok(_value) => println!("Item updated successfully!"),
        Err(_error) => panic!("Could not update item!"),
    };

    let response = Response::builder()
        .status(200)
        .body(())
        .expect("Failed to return 200.");

    Ok(response)
}
