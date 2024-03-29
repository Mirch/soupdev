# API Gateway
variable "main_api" {
    description = "The representation of the root API."
    type = any
}

variable "main_api_stage" {
    description = "The representation of the root API stage."
    type = any
}

# Client S3 configuration
variable "client_domain" {
   description = "The domain used by the client."
  type = string
}


# Stripe
variable "stripe_api_token" {
  type = string
}

# Payments
variable "create_payment_bin_path" {
  description = "The binary path for the CreatePayment lambda."

  type    = string
  default = "./bin/create_payment/bootstrap"
}

variable "log_payment_bin_path" {
  description = "The binary path for the LogPayment lambda."

  type    = string
  default = "./bin/log_payment/bootstrap"
}

variable "get_payments_bin_path" {
  description = "The binary path for the LogPayment lambda."

  type    = string
  default = "./bin/get_payments/bootstrap"
}
