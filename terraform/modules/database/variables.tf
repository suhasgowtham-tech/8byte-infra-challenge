variable "environment" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "List of private subnet IDs for the database tier"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The security group ID of the application tier to allow DB traffic ingress"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "fubodb"
}

variable "db_user" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}
