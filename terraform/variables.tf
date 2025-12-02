# VPC Variables
variable "vpc_cidr" {
    type        = string
    description = "This is the VPC CIDR block"
}

variable "vpc_name" {
    type        = string
    description = "This is the VPC name"
}

variable "igw_name" {
    type        = string
    description = "This is the Internet Gateway name"
}

variable "eip_domain" {
    type        = string
    description = "This is the NAT EIP domain type"
}

variable "public_route_cidr" {
    type        = string
    description = "This is the public route anywhere 0.0.0.0"
}

# ECR Variables
variable "ecr_repository_name" {
    type = string
    description = "This is the Private ECR repository name"
}

variable "ecr_mutability" {
    type = string
    description = "This is the ECR repository image tag mutability option"
}

variable "ecr_encryption" {
    type = string
    description = "This is the ECR repository encryption configuration"
}

# Task Definition Variables
variable "task_exec_name" {
    type = string
    description = "This is the ECS Task Execution role"
}

variable "log_group_name" {
    type        = string
    description = "This is the ECS Task definition CloudWatch Log group name"
}

variable "task_definition_name" {
    type        = string
    description = "This is the Task definition family name"
}

variable "network_mode" {
    type        = string
    description = "This is the Task definition networking mode for containers in the ECS Task"
}

variable "launch_type" {
    type        = string
    description = "This is the infrastructure launch type for task definition"
}

variable "task_cpu" {
    type        = string
    description = "This is the amount of CPU for ECS Tasks"
}

variable "task_memory" {
    type        = string
    description = "This is the amount of Memory for ECS Tasks"
}

variable "container_name" {
    type        = string
    description = "This is the container name"
}

# ECS Variables
variable "ec2_iam_role_name" {
    type        = string
    description = "This is the EC2 IAM Role for ECS"
}

variable "ec2_instance_profile_name" {
    type        = string
    description = "This is the EC2 Instance profile name for ECS EC2"
}

variable "instance_type" {
    type        = string
    description = "This is the EC2 instance type"
}

variable "cluster_name" {
    type        = string
    description = "This is the ECS Cluster name"
}

variable "service_name" {
    type        = string
    description = "This the ECS Cluster Service name"
}

# ALB Variables
variable "target_type" {
    type        = string
    description = "This is the Target Group target type"
}

variable "target_group_port" {
    type        = number
    description = "This is the target group port number"
}

variable "listener_port" {
    type        = number
    description = "This is the HTTP listener rule port number"
}

variable "alb_name" {
    type        = string
    description = "This is the Application load balancer name"
}

variable "lb_type" {
    type        = string
    description = "This is the Load balancer type"
}

variable "tg_name" {
    type        = string
    description = "This is the Target group name"
}

# CodeBuild Variables
variable "codebuild_iam_role" {
    type        = string
    description = "This is the CodeBuild IAM role"
}

variable "codebuild_project_name" {
    type        = string
    description = "value"
}

variable "source_type" {
    type        = string
    description = "value"
}

variable "account_id" {
    type        = string
    description = "value"
}

variable "region" {
    type        = string
    description = "value"
}

variable "codebuild_logs" {
    type        = string
    description = "value"
}

# CodePipeline Variables
variable "bucket_name" {
    type        = string
    description = "This is the S3 bucket for storing artifacts"
}

variable "connection" {
    type        = string
    description = "This is the GitHub and AWS connection"
}

variable "provider_type" {
    type        = string
    description = "This is the code source provider"
}

variable "codepipeline_role_name" {
    type        = string
    description = "This is the CodePipeline IAM Role name"
}

variable "pipeline_name" {
    type = string
}

variable "github_repo_url" {
    type        = string
    description = "value"
}