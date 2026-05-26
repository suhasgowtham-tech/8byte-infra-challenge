# 1. Load Balancer Security Group (Open to public web traffic)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Allows public web traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic to app instances"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}

# 2. Application Tier Security Group (Accepts traffic exclusively from the ALB)
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.environment}-ecs-tasks-sg"
  description = "Isolates containers; accepts traffic only from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Traffic from ALB only"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic for image pulls and API patches"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-ecs-tasks-sg"
  }
}

# 3. Database Tier Security Group (Accepts traffic exclusively from ECS containers)
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Completely seals database; accepts traffic only from application tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL access from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    description = "Block all outbound database connection initiates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}