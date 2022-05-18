terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    archive = {
      source  = "hashicorp/archive"
    }
    stripe = {
      source  = "franckverrot/stripe"
      version = "1.8.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "stripe" {
  # NOTE: This is populated from the `TF_VAR_stripe_api_token` environment variable.
  api_token = var.stripe_api_token
}