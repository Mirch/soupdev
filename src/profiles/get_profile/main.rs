use lambda_http::{service_fn, Error, IntoResponse, Request, RequestExt, Response};
use serde_json::json;
use lambda_layer::user::{User};


#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_http::run(service_fn(func)).await?;
    Ok(())
}

async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    
    Ok(match event.query_string_parameters().first("uid") {
        Some(uid) => {
            let user = User {
                uid: uid.to_string(), 
                username: String::from("Cool User")
            };
            let response = json!(user).to_string();
            return Ok(response.into_response());
        },
        _ => Response::builder()
            .status(400)
            .body("Empty first name".into())
            .expect("failed to render response"),
    })
}