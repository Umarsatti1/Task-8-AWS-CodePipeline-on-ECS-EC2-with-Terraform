output "alb_arn" {
    value       = aws_lb.alb.arn
    description = "ARN for Application Load Balancer"
}

output "target_group_arn" {
    value       = aws_lb_target_group.ip_target_group.arn
    description = "ARN for ALB Target Group"
}

output "alb_dns_name" {
    value       = aws_lb.alb.dns_name
    description = "ALB DNS Name to access web application"
}