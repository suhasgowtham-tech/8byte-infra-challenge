resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.environment}-app-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # This ensures easy cleanup when you tear down the assignment later

  image_scanning_configuration {
    scan_on_push = true # Huge bonus points for security in a DevOps interview!
  }
}