resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_mutability
  force_delete         = true
  
  encryption_configuration {
    encryption_type = var.ecr_encryption
  }

  image_scanning_configuration {
    scan_on_push = false
  }
}