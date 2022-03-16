terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49.0"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
  default_tags {
    tags = module.tags.tags
  }
}