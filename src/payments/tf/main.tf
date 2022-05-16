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
    }
  }
}