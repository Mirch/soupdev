use lambda_http::{http::Request, Body, RequestExt};

pub fn get_header_value(event: &Request<Body>, key: &str) -> String {
    let headers = event.headers();

    match headers.get(key){ 
        Some(value) => value.to_str().unwrap().to_string(),
        None => panic!("Missing signature.")
    }
}

pub fn get_query_string_parameter(event: &Request<Body>, key: &str) -> String {
    match event.query_string_parameters().first(key) {
        Some(value) => String::from(value),
        None => panic!("Query parameter {} not found.", key),
    }
}

pub fn get_body_as_json_string(event: &Request<Body>) -> String {
    let body = match event.body() {
        Body::Text(value) => value,
        _ => panic!("Wrong body format."),
    };
    let result = serde_json::from_str(body);

    match result {
        Ok(value) => value,
        Err(_err) => panic!("Wrong body format.")
    }
}