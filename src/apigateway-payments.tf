# CREATE PAYMENT
resource "aws_apigatewayv2_integration" "create_payment_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Create Payment"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.create_payment_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_payment_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /pay"
  target    = "integrations/${aws_apigatewayv2_integration.create_payment_integration.id}"
}

resource "aws_lambda_permission" "create_payment_api_permission" {
  function_name = aws_lambda_function.create_payment_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/${split("/", aws_apigatewayv2_route.create_payment_route.route_key)[1]}"
}

# LOG PAYMENT
resource "aws_apigatewayv2_integration" "log_payment_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Log Payment"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.log_payment_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "log_payment_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /payment/log"
  target    = "integrations/${aws_apigatewayv2_integration.log_payment_integration.id}"
}

resource "aws_lambda_permission" "log_payment_api_permission" {
  function_name = aws_lambda_function.log_payment_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/*"
}