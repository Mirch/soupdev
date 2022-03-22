variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-1"
}

variable "get_profile_bin_path" {
  description = "The binary path for the GetProfile lambda."

  type    = string
  default = "./bin/get_profile/bootstrap"
}

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