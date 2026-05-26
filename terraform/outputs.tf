output "application_load_balancer_url" {
  description = "The public endpoint to reach the cluster application"
  value       = module.compute.alb_dns_name
}