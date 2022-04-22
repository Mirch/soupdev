use aws_sdk_dynamodb::model::{AttributeValue, AttributeValue::*};
use aws_sdk_dynamodb::Client;
use lambda_http::{Error, IntoResponse, Request, Response};
use common::environment::{get_env_variable, USERS_USERNAME_INDEX, USERS_TABLE_NAME};
use common::request_utils::get_query_string_parameter;
use common::user::User;
use serde_json::json;

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    let users_table_name = get_env_variable(USERS_TABLE_NAME);
    let username_index = get_env_variable(USERS_USERNAME_INDEX);

    let uid = get_query_string_parameter(&event, "uid");
    let username = get_query_string_parameter(&event, "username");

    if uid.is_empty() && username.is_empty() {
        return Ok(Response::builder()
            .status(400)
            .body("Provide either an uid or a username".into())
            .expect("failed to render response"));
    }

    let query_key = if !uid.is_empty() { "uid" } else { "username" };
    let key_value = if !uid.is_empty() { uid } else { username };

    let shared_config = aws_config::from_env().load().await;
    let client = Client::new(&shared_config);
    let query = client
        .query()
        .table_name(users_table_name)
        .index_name(username_index)
        .key_condition_expression("#key = :value".to_string())
        .expression_attribute_names("#key".to_string(), query_key)
        .expression_attribute_values(
            ":value".to_string(),
            AttributeValue::S(key_value.to_string()),
        );

    let result = match query.send().await {
        Ok(resp) => {
            if resp.count == 0 {
                // return 
            }
            let item = resp.items().unwrap().first().unwrap();
            let uid = match &item["uid"] {
                S(v) => v.clone(),
                _ => "".to_string(),
            };
            let username = match &item["username"] {
                S(v) => v.clone(),
                _ => "".to_string(),
            };
            let headline = match &item["headline"] {
                S(v) => v.clone(),
                _ => "".to_string(),
            };
            let description = match &item["description"] {
                S(v) => v.clone(),
                _ => "".to_string(),
            };

            User {
                uid,
                username,
                headline,
                description,
            }
        }
        Err(e) => {
            println!("Error: {}", e);
            User::empty()
        }
    };

    let response = json!(result).to_string();
    Ok(response.into_response())
}
