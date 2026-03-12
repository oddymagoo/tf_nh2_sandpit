##
## Providers
##
terraform {
  required_version = "~> 1.11.4"
  region = "us-east-1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}
