use aws_sdk_dynamodb::model::{AttributeValue, AttributeValue::*, Select};
use aws_sdk_dynamodb::Client;
use lambda_http::{Error, IntoResponse, Request, RequestExt, Response};
use lambda_layer::environment::get_env_variable;
use lambda_layer::user::User;
use serde_json::json;

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    let users_table_name = get_env_variable("USERS_TABLE_NAME");

    let uid = match event.query_string_parameters().first("uid") {
        Some(value) => String::from(value),
        _ => String::from(""),
    };

    let username = match event.query_string_parameters().first("username") {
        Some(value) => String::from(value),
        _ => String::from(""),
    };

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
        .key_condition_expression("#key = :value".to_string())
        .expression_attribute_names("#key".to_string(), query_key)
        .expression_attribute_values(
            ":value".to_string(),
            AttributeValue::S(key_value.to_string()),
        )
        .select(Select::AllAttributes)
        .send();

    let result = match query.await
    {
        Ok(resp) => {
            if resp.count == 0 {
                ()
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

            User { uid, username }
        }
        Err(e) => {
            println!("Error: {}", e.to_string());
            User {
                uid: "".to_string(),
                username: "".to_string(),
            }
        }
    };

    let response = json!(result).to_string();
    Ok(response.into_response())
}
