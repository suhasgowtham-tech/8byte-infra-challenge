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
