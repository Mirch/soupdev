# API
resource "aws_apigatewayv2_api" "api" {
  name          = "soupdev API"
  description   = "soupdev API"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "soupdev API deployment"

  triggers = {
    redeployment = sha1(join(",", [
      jsonencode(module.profiles.aws_apigatewayv2_integration.get_profile_integration),
      jsonencode(module.profiles.aws_apigatewayv2_route.get_profile_route),
      jsonencode(module.payments.aws_apigatewayv2_integration.create_payment_integration),
      jsonencode(module.payments.aws_apigatewayv2_route.create_payment_route),
      ],
    ))
  }

  lifecycle {
    create_before_destroy = true
  }
}