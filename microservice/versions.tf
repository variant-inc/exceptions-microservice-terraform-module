terraform {
  backend "s3" {}
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
