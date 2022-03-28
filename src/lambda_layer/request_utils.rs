use lambda_http::{http::Request, Body, RequestExt};
use serde_json::Error;
use stripe::WebhookEvent;

pub fn get_header_value(event: &Request<Body>, key: &str) -> String {
    let headers = event.headers();

    match headers.get(key) {
        Some(value) => value.to_str().unwrap().to_string(),
        None => panic!("Missing signature."),
    }
}

pub fn get_query_string_parameter(event: &Request<Body>, key: &str) -> String {
    match event.query_string_parameters().first(key) {
        Some(value) => String::from(value),
        None => String::from(""),
    }
}

pub fn get_body_as_json_string(event: &Request<Body>) -> String {
    let body = match event.body() {
        Body::Text(value) => value.as_str(),
        _ => panic!("Wrong body format."),
    };

    println!("Body: {}", body);
    let result: Result<WebhookEvent, Error> = serde_json::from_str(body);

    let webhook_event = match result {
        Ok(value) => value,
        Err(err) => panic!("{}", err),
    };

    match serde_json::to_string(&webhook_event) {
        Ok(value) => value,
        Err(err) => panic!("{}", err),
    }
}
