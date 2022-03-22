use lambda_http::{Error, IntoResponse, Request, Response};

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {
    println!("{:?}", event.body()); 

    Ok("hello")
}