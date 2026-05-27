# =============================================================
# MONITORING MODULE
# Part 3: Monitoring & Logging - Full Implementation
# Covers: Log Groups, Metric Alarms, 2 CloudWatch Dashboards
# =============================================================

# ==========================================
# 1. CENTRALIZED LOG GROUPS (PART 3.2)
# ==========================================

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.environment}-core-api"
  retention_in_days = 30
  tags = {
    Environment = var.environment
    Layer       = "Application-Logging"
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/8byte/${var.environment}/system"
  retention_in_days = 30
  tags = {
    Environment = var.environment
    Layer       = "System-Logging"
  }
}

resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/8byte/${var.environment}/access"
  retention_in_days = 30
  tags = {
    Environment = var.environment
    Layer       = "Access-Logging"
  }
}

# ==========================================
# 2. METRIC ALARMS (PART 3.1)
# ==========================================

resource "aws_cloudwatch_metric_alarm" "container_cpu_high" {
  alarm_name          = "${var.environment}-container-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
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

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.environment}-rds-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "RDS CPU utilization exceeded 75% - investigate query load."
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.environment}-rds-free-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Minimum"
  threshold           = 5368709120 # 5GB in bytes
  alarm_description   = "RDS free storage dropped below 5GB - disk expansion required."
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-5xx-error-rate-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5XX error count exceeded 10 in 60s - application instability detected."
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  alarm_name          = "${var.environment}-alb-response-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p99"
  threshold           = 2
  alarm_description   = "ALB p99 response latency exceeded 2 seconds."
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

# ==========================================
# 3. OPS DASHBOARDS (PART 3.3)
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
          title  = "ECS Fargate Container Compute Capacity Metrics"
          period = 300
          stat   = "Average"
          region = "us-east-1"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ALB Request Rate & Error Count"
          period = 60
          stat   = "Sum"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_ELB_5XX_Count", ".", "."],
            [".", "HTTPCode_ELB_4XX_Count", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Target Response Latency (p99)"
          period = 60
          stat   = "p99"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB Healthy vs Unhealthy Host Count"
          period = 60
          stat   = "Average"
          region = "us-east-1"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "UnHealthyHostCount", ".", "."]
          ]
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
          title  = "PostgreSQL Operational Telemetry Pool"
          period = 300
          stat   = "Average"
          region = "us-east-1"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier],
            [".", "DatabaseConnections", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "RDS Free Storage Space (Bytes)"
          period = 300
          stat   = "Minimum"
          region = "us-east-1"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_instance_identifier]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS Read & Write Latency"
          period = 60
          stat   = "Average"
          region = "us-east-1"
          metrics = [
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", var.db_instance_identifier],
            [".", "WriteLatency", ".", "."]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS Throughput (Read/Write IOPS)"
          period = 300
          stat   = "Average"
          region = "us-east-1"
          metrics = [
            ["AWS/RDS", "ReadIOPS", "DBInstanceIdentifier", var.db_instance_identifier],
            [".", "WriteIOPS", ".", "."]
          ]
        }
      }
    ]
  })
}