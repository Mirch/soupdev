use lambda_http::{service_fn, Error};

mod function;
use function::func;

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_http::run(service_fn(func)).await?;
    Ok(())
}