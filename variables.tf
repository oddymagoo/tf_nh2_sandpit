#Variables
variable "environment" {
  description = "The environment where resources will be created (e.g. dev, tst, uat, prd)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}