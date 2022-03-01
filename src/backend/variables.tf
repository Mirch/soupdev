variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-west-1"
}

variable "get_profile_bin_path" {
  description = "The binary path for the GetProfile lambda."

  type    = string
  default = "./bin/lambdas/get_profile/bootstrap"
}