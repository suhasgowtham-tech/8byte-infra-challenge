variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1" # Mumbai region
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "The CIDR block for the production VPC"
  type        = string
  default     = "10.0.0.0/16"
}