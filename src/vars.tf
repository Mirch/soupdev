variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-1"
}

variable "stripe_api_token" {
  type = string
}