terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    archive = {
      source  = "hashicorp/archive"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}