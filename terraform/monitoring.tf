# ==========================================
# CENTRALIZED LOGGING (Log Groups)
# ==========================================

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/8byte-app-logs"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/ec2/8byte-system-logs"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/alb/8byte-access-logs"
  retention_in_days = 14
}

# ==========================================
# INFRASTRUCTURE & DB DASHBOARD
# ==========================================

resource "aws_cloudwatch_dashboard" "main_dashboard" {
  dashboard_name = "8Byte-Production-Monitoring"

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
            ["AWS/ECS", "CPUUtilization", "ClusterName", "production-core-cluster"],
            [".", "MemoryUtilization", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Application Compute (ECS) Performance"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "8byte-postgres-db"],
            [".", "DatabaseConnections", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "PostgreSQL Database Health"
        }
      }
    ]
  })
}
