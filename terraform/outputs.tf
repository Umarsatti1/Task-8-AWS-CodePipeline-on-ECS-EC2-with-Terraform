output "alb_dns_name" {
    value       = module.alb.alb_dns_name
    description = "ALB DNS Name to access web application"
}