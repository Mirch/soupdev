terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    stripe = {
      source  = "franckverrot/stripe"
      version = "1.8.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = "~> 1.0"

  cloud {
    organization = "mirch"

    workspaces {
      name = "soupdev"
    }
  }
}

provider "aws" {
  alias  = "main"
  region = "eu-west-1"
}

provider "stripe" {
  alias = "main"
  # NOTE: This is populated from the `TF_VAR_stripe_api_token` environment variable.
  api_token = var.stripe_api_token
}

provider "archive" {
  alias = "main"
}

# MODULES
module "client" {
  source = "./client/tf"

  providers = {
    aws = aws.main
  }
}

module "payments" {
  source = "./payments/tf"

  stripe_api_token = var.stripe_api_token
  main_api         = aws_apigatewayv2_api.api
  main_api_stage   = aws_apigatewayv2_stage.api_stage
  client_domain    = module.client.domain

  providers = {
    aws     = aws.main
    archive = archive.main
  }
}

module "profiles" {
  source = "./profiles/tf"

  main_api = aws_apigatewayv2_api.api

  providers = {
    aws     = aws.main
    archive = archive.main
  }
}

