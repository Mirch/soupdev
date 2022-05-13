use std::str::FromStr;

use aws_sdk_dynamodb::model::AttributeValue;
use aws_sdk_dynamodb::Client;
use lambda_http::Response;
use lambda_http::{Error, IntoResponse, Request};
use soupdev_common::environment::{ORDER_ID_INDEX_NAME, get_env_variable};
use soupdev_common::environment::PAYMENTS_TABLE_NAME;
use soupdev_common::environment::STRIPE_WEBHOOK_SECRET;
use soupdev_common::payment::PaymentStatus;
use soupdev_common::request_utils::get_body_as_json_string;
use soupdev_common::request_utils::get_header_value;
use stripe::EventObject;
use stripe::PaymentIntentId;

const SIGNATURE_KEY: &str = "Stripe-Signature";

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    let order_id_index = get_env_variable(ORDER_ID_INDEX_NAME);

    let signature = get_header_value(&event, SIGNATURE_KEY);
    let secret = get_env_variable(STRIPE_WEBHOOK_SECRET);
    let payload = get_body_as_json_string(&event);

    let webhook_event = match stripe::Webhook::construct_event(&payload, &signature, &secret) {
        Ok(result) => result,
        Err(err) => panic!("{}", err),
    };

    let mut intent_id = PaymentIntentId::from_str("pi_").unwrap(); // placeholder payment intent
    if let EventObject::Charge(value) = webhook_event.data.object {
        let expandable_intent = *(value.payment_intent.unwrap());

        if let stripe::Expandable::Id(id) = expandable_intent {
            intent_id = id
        }
    };

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let table_name = get_env_variable(PAYMENTS_TABLE_NAME);

    let query = client
        .query()
        .table_name(&table_name)
        .index_name(order_id_index)
        .key_condition_expression("#key = :value".to_string())
        .expression_attribute_names("#key".to_string(), "order_id")
        .expression_attribute_values(
            ":value".to_string(),
            AttributeValue::S(intent_id.to_string()),
        );

    println!("Query: {:?}", query);

    let response = match query.send().await {
        Ok(response) => response,
        Err(error) => panic!("{}", error),
    };
    let payment = response.items().unwrap().first().unwrap();
    let payment_id = payment.get("id").unwrap().to_owned();

    println!("{:?}", payment_id);

    let update = client
        .update_item()
        .table_name(&table_name)
        .key("id", payment_id)
        .update_expression("SET #status=:s")
        .expression_attribute_names("#status".to_string(), "status".to_string())
        .expression_attribute_values(
            ":s".to_string(),
            AttributeValue::N((PaymentStatus::Paid as i32).to_string()),
        );

    let _result = match update.send().await {
        Ok(_value) => println!("Item updated successfully!"),
        Err(error) => panic!("{}", error),
    };

    let response = Response::builder()
        .status(200)
        .body(())
        .expect("Failed to return 200.");

    Ok(response)
}
