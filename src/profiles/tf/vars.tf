# API Gateway
variable "main_api" {
    description = "The representation of the root API."

    type = any
}

# Profile
variable "get_profile_bin_path" {
  description = "The binary path for the GetProfile lambda."

  type    = string
  default = "./bin/get_profile/bootstrap"
}