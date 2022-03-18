terraform {
  required_providers {
    aws = {
      version = "~> 3.49.0"
    }
    helm = {
      version = "~> 1.3.0"
    }
    kubernetes = {
      version = "~> 1.13.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
  default_tags {
    tags = module.tags.tags
  }
}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "sns_key" {
  name = var.kms_key_alias_sns
}

# var.environment is set in scripts/octo/plan.sh & delpoy.sh:
locals {
  aws_account_id                   = data.aws_caller_identity.current.account_id
}