use aws_sdk_dynamodb::{model::AttributeValue, Client};
use lambda_http::{Error, IntoResponse, Request};
use lambda_layer::{
    environment::{get_env_variable, PAYMENTS_TABLE_NAME, TO_INDEX_NAME},
    request_utils::get_query_string_parameter, payment::{Payment, PaymentStatus, PaymentDTO},
};
use serde_json::json;

const USERNAME_PARAMETER: &str = "username";

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    let payments_table = get_env_variable(PAYMENTS_TABLE_NAME);
    let order_id_index = get_env_variable(TO_INDEX_NAME);

    let username = get_query_string_parameter(&event, USERNAME_PARAMETER);

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let query = client
        .query()
        .table_name(&payments_table)
        .index_name(order_id_index)
        .key_condition_expression("#key = :value".to_string())
        .expression_attribute_names("#key".to_string(), "to")
        .expression_attribute_values(":value".to_string(), AttributeValue::S(username));

    let result = match query.send().await {
        Ok(value) => value,
        Err(error) => panic!("{:?}", error),
    };

    let result_items = result.items().unwrap();
    let mut items = Vec::new();
    for item in result_items {
        let payment = Payment::from_dynamo_hashmap(item);
        if payment.status == PaymentStatus::Paid {
            items.push(PaymentDTO::from_payment(Payment::from_dynamo_hashmap(item)));
        }
    }

    let result = json!(items).to_string();
    Ok(result)
}
