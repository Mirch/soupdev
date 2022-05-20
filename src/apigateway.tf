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

resource "aws_apigatewayv2_route" "sample_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /"
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "soupdev API deployment"

  lifecycle {
    create_before_destroy = true
  }
}