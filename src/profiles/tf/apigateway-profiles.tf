# GET PROFILE
resource "aws_apigatewayv2_integration" "get_profile_integration" {
  api_id           = var.main_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Get Profile"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.get_profile_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_profile_route" {
  api_id    = var.main_api.id
  route_key = "GET /profile"
  target    = "integrations/${aws_apigatewayv2_integration.get_profile_integration.id}"
}

resource "aws_lambda_permission" "get_profile_api_permission" {
  function_name = aws_lambda_function.get_profile_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.main_api.execution_arn}/*/*/${split("/", aws_apigatewayv2_route.get_profile_route.route_key)[1]}"
}