##
## Variables
##
variable "account_id" {
  description = "The AWS Account ID where resources will be created"
  type        = string
  default     = "939822963033"
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The environment where resources will be created (e.g. dev, tst, uat, prd)"
  type        = string
  default     = "dev"
}