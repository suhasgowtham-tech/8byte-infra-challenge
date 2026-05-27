# =============================================================
# TERRAFORM REMOTE STATE BACKEND
# S3 for state storage + DynamoDB for state locking
# Prevents concurrent modifications in team environments
# =============================================================

terraform {
  backend "s3" {
    bucket         = "8byte-infra-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}