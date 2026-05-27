variable "environment" {
  description = "Deployment environment scope"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster to track host telemetry"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the target ECS service"
  type        = string
}

variable "db_instance_identifier" {
  description = "The RDS PostgreSQL instance identifier for storage tracking"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix used for load balancer CloudWatch metric dimensions"
  type        = string
}

variable "aws_region" {
  description = "AWS region where all resources are deployed"
  type        = string
  default     = "us-east-1"
}