##
## Providers
##
terraform {
  required_version = "~> 1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}



provider "aws" {
  region              = var.aws_region
  #allowed_account_ids = [var.account_id]
}