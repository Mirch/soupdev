resource "stripe_webhook_endpoint" "my_endpoint" {
  url = format("%s/%s", aws_apigatewayv2_stage.api_stage.invoke_url, "/payment/log")

  enabled_events = [
    "charge.succeeded",
  ]
}
