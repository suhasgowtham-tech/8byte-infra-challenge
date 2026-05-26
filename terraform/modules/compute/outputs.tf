output "alb_dns_name" {
  description = "The public facing URL of the production platform"
  value       = aws_lb.main.dns_name
}

output "ecs_tasks_security_group_id" {
  description = "Exported security perimeter ID for backend linkage"
  value       = aws_security_group.ecs_tasks.id
}

output "ecs_cluster_name" {
  description = "Exported cluster identification for metric alarm targeting"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Exported service identification for metric alarm targeting"
  value       = aws_ecs_service.main.name
}