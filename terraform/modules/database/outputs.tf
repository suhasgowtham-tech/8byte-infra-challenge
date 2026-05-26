output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "db_user" {
  value = aws_db_instance.postgres.username
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "db_instance_identifier" {
  description = "Exported database instance ID for engine telemetry tracking"
  value       = aws_db_instance.postgres.identifier
}