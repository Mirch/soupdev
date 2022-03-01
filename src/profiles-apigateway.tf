# API
resource "aws_apigatewayv2_api" "profiles_api" {
  name          = "Profiles API"
  description   = "Profiles API"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "profiles_api_stage" {
  api_id      = aws_apigatewayv2_api.profiles_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "profiles_api_deployment" {
  api_id      = aws_apigatewayv2_api.profiles_api.id
  description = "Profiles API deployment"

  triggers = {
    redeployment = sha1(join(",", [
      jsonencode(aws_apigatewayv2_integration.get_profile_integration),
      jsonencode(aws_apigatewayv2_route.get_profile_route),
      ],
    ))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# GET PROFILE
resource "aws_apigatewayv2_integration" "get_profile_integration" {
  api_id           = aws_apigatewayv2_api.profiles_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Get Profile"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.get_profile_lambda.invoke_arn

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_profile_route" {
  api_id    = aws_apigatewayv2_api.profiles_api.id
  route_key = "GET /profile"
  target    = "integrations/${aws_apigatewayv2_integration.get_profile_integration.id}"
}

resource "aws_lambda_permission" "get_profile_api_permission" {
  function_name = aws_lambda_function.get_profile_lambda.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.profiles_api.execution_arn}/*/*/${split("/", aws_apigatewayv2_route.get_profile_route.route_key)[1]}"
}