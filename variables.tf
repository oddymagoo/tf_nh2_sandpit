##
## Variables
##
variable "account_id" {
  description = "The AWS Account ID where resources will be created"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment where resources will be created (e.g. dev, tst, uat, prd)"
  type        = string
}

variable "application_shortname" {
  description = "The short name of the application"
  type        = string
  default     = "nothub2"
}