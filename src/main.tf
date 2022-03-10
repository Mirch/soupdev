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
    null = {
      source = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = "~> 1.0"

  cloud {
    organization = "mirch"

    workspaces {
      name = "suppdev"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  profile    = "personal"
  access_key = "AKIAVG7RRE6AMDWSPNED"
  secret_key = "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"
}