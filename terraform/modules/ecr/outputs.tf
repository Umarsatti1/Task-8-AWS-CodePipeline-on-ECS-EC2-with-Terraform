output "ecr_image_uri" {
    value = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_repository_name" {
    value = var.ecr_repository_name
}