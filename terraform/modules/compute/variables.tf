variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "Target infrastructure VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public network subnets for the Load Balancer"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "Private isolated app subnets for Fargate containers"
  type        = list(string)
}

variable "app_port" {
  description = "Port exposed by the Node.js application"
  type        = number
  default     = 3000
}
