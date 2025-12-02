output "task_definition_arn" {
    value       = aws_ecs_task_definition.task_definition.arn
    description = "This is the ARN of Task Definition"
}

output "container_name" {
    value       = var.container_name
    description = "This is the name of the container in ECS Task Definition"
}