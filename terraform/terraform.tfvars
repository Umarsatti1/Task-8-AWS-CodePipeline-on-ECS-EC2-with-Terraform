# VPC Variables
vpc_cidr          = "192.168.0.0/16"
vpc_name          = "Umarsatti-VPC"
igw_name          = "Umarsatti-IGW"
eip_domain        = "vpc"
public_route_cidr = "0.0.0.0/0"

# ECR Variables
ecr_repository_name = "python-ecr"
ecr_mutability      = "MUTABLE"
ecr_encryption      = "AES256"

# Task Definition Variables
task_exec_name       = "ecs-ec2-task-execution-iam-role"
log_group_name       = "ecs-task-definition-log-group"
task_definition_name = "python-flask-task-definition"
network_mode         = "bridge"
launch_type          = "EC2"
task_cpu             = "256"
task_memory          = "512"
container_name       = "flask"

# ECS Variables
ec2_iam_role_name         = "ec2-instance-role-for-ecs"
ec2_instance_profile_name = "amazon-ec2-instance-profile"
instance_type             = "t3.micro"
cluster_name              = "flask-ecs-cluster"
service_name              = "flask-ecs-service"

# ALB Variables
target_type       = "instance"
target_group_port = 5000
listener_port     = 80
alb_name          = "ecs-ec2-alb"
lb_type           = "application"
tg_name           = "ecs-ec2-target-group"

# CodeBuild Variables
codebuild_iam_role     = "CodeBuild-iam-role-ecs-ec2"
codebuild_project_name = "codebuild-ecs-ec2-project"
account_id             = "730335208305"
region                 = "us-east-1"
codebuild_logs         = "codebuild-ecs-ec2-log-group"

# CodePipeline Variables
bucket_name            = "codepipeline-umarsatti-ecs-ec2-bucket"
connection             = "aws-github-connection"
provider_type          = "GitHub"
codepipeline_role_name = "CodePipeline-iam-role-ecs-ec2"
pipeline_name          = "codePipeline-ecs-ec2-project"
github_repo_url        = "Umarsatti1/Task-8-AWS-CodePipeline-on-ECS-EC2-with-Terraform"
