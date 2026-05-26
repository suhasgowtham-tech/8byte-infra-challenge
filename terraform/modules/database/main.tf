# Generate a secure, random password for the PostgreSQL master user
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Subnet Group to assign our RDS instance to the private database subnets
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# Dedicated Security Group for the Database Tier
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Allow inbound PostgreSQL traffic from the application layer only"
  vpc_id      = var.vpc_id

  # Ingress rule: Port 5432 strictly bound to the app security group ID
  ingress {
    description     = "PostgreSQL access from app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  # Egress rule: Allow all outbound signals
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-db-sg"
  }
}

# Production-grade PostgreSQL RDS Instance
resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment}-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro" 
  allocated_storage      = 20
  max_allocated_storage  = 100 
  db_name                = var.db_name
  username               = var.db_user
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true 

  tags = {
    Name = "${var.environment}-postgresql"
  }
}