# ==========================================
# 1. CENTRALIZED LOG GROUPS (PART 3.2)
# ==========================================

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.environment}-core-api"
  retention_in_days = 30 # Aggressive cost control retention window

  tags = {
    Environment = var.environment
    Layer       = "Application-Logging"
  }
}

# ==========================================
# 2. METRIC ALARM ALERTS (PART 3.1)
# ==========================================

resource "aws_cloudwatch_metric_alarm" "container_cpu_high" {
  alarm_name          = "${var.environment}-container-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70 # Trigger alert when resource capacity touches 70% threshold
  alarm_description   = "This metric monitors container tasks CPU limits for auto-scaling triggers."
  
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "container_memory_high" {
  alarm_name          = "${var.environment}-container-memory-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors container tasks Memory utilization saturation."

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

# ==========================================
# 3. OPS DASHBOARDS CONFIGURATION (PART 3.3)
# ==========================================

# Dashboard 1: Core SRE Platform Performance Dashboard
resource "aws_cloudwatch_dashboard" "platform_health" {
  dashboard_name = "${var.environment}-sre-platform-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "ECS Fargate Container Compute Capacity Metrics"
        }
      }
    ]
  })
}

# Dashboard 2: Database Storage & Engine Analytics Dashboard
resource "aws_cloudwatch_dashboard" "database_health" {
  dashboard_name = "${var.environment}-database-analytics-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier ],
            [ ".", "DatabaseConnections", ".", "." ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "PostgreSQL Operational Telemetry Pool"
        }
      }
    ]
  })
}