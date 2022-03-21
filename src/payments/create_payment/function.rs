use lambda_http::{Error, IntoResponse, Request, Response};
use lambda_layer::environment::get_env_variable;

pub async fn func(_event: Request) -> Result<impl IntoResponse, Error> {
    let domain = format!("http://{}", get_env_variable("DOMAIN"));

    let secret_key = "sk_test_HmtYQSWjVu1dHEb4CvXxkmBc00MEphxieW";
    let client = stripe::Client::new(secret_key);

    let cancel_url  = format!("{}/payment/cancel", domain);
    let success_url  = format!("{}/payment/success", domain);


    let mut params = stripe::CreateCheckoutSession::new(cancel_url.as_str(), success_url.as_str());

    params.line_items = Some(Box::new(vec![stripe::CreateCheckoutSessionLineItems {
        price_data: Some(Box::new(stripe::CreateCheckoutSessionLineItemsPriceData {
            currency: stripe::Currency::USD,
            product_data: Some(Box::new(
                stripe::CreateCheckoutSessionLineItemsPriceDataProductData {
                    name: "Test".to_string(),
                    description: Option::None,
                    images: Option::None,
                    metadata: Default::default(),
                    tax_code: Option::None,
                },
            )),
            unit_amount: Some(Box::new(10)),
            product: Option::None,
            recurring: Option::None,
            tax_behavior: Option::None,
            unit_amount_decimal: Option::None,
        })),
        quantity: Some(Box::new(1)),
        adjustable_quantity: Option::None,
        description: Option::None,
        dynamic_tax_rates: Option::None,
        price: Option::None,
        tax_rates: Option::None,
    }]));
    params.mode = Some(stripe::CheckoutSessionMode::Payment);

    let session = stripe::CheckoutSession::create(&client, params)
        .await
        .unwrap();
    let url = session.url.unwrap();

    let response = Response::builder()
        .status(303)
        .header("Location", *url)
        .body(())
        .expect("Failed to get redirect url.");

    Ok(response)
}
