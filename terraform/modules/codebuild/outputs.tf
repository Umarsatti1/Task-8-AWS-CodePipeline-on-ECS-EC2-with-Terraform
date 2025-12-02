output "codebuild_project_arn" {
    value = aws_codebuild_project.flask_project.arn
}

output "codebuild_project_name" {
    value = aws_codebuild_project.flask_project.name
}