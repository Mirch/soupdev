use std::str::FromStr;

use stripe::PaymentIntent;
use stripe::EventObject;
use stripe::PaymentIntentId;
use uuid::Uuid;
use lambda_http::{Error, IntoResponse, Request, Body};
use lambda_layer::{environment::get_env_variable, payment::Payment};

const signature_key: &str = "STRIPE_SIGNATURE";
const secret_key: &str = "STRIPE_WEBHOOK_SECRET";

pub async fn func(event: Request) -> Result<impl IntoResponse, Error> {

    let headers = event.headers();
    let body = match event.body() {
        Body::Text(value) => value,
        _ => panic!("Wrong body format.")
    };

    let signature = match headers.get(signature_key){ 
        Some(value) => value.to_str().unwrap(),
        None => panic!("Missing signature.")
    };
    let secret = get_env_variable(secret_key);
    let payload = serde_json::from_str(body).unwrap();

    let webhook_event = stripe::Webhook::construct_event(
        payload, &signature, &secret
    );

    let webhook_event = match webhook_event {
        Ok(result) => result,
        Err(err) => panic!("Could not handle event.")
    };

    let mut intent_id = PaymentIntentId::from_str("").unwrap();
    match webhook_event.data.object {
        EventObject::PaymentIntent(value) => intent_id = value.id,
        _ => ()
    };

    let payment = Payment {
        id: Uuid::new_v4().to_string(),
        from: String::new(),
        to: String::new(),
        intent_id: String::from(intent_id.as_str()),
        amount: 0,
    };

    Ok("hello")
}