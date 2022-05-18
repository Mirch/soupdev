resource "stripe_webhook_endpoint" "successful_payments" {
  url = format("%s%s", var.main_api_stage.invoke_url, "payment/log")

  enabled_events = [
    "charge.succeeded",
  ]
}
