# Output value definitions

output "invoke_url" {
  value = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "client_bucket" {
  value = aws_s3_bucket.soupdev-client.bucket
}