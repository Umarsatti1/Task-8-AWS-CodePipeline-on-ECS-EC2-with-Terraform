# VPC Module
module "vpc" {
    source            = "./modules/vpc"
    vpc_cidr          = var.vpc_cidr
    vpc_name          = var.vpc_name
    igw_name          = var.igw_name
    eip_domain        = var.eip_domain
    public_route_cidr = var.public_route_cidr
}

# ECR Module
module "ecr" {
    source              = "./modules/ecr"
    ecr_repository_name = var.ecr_repository_name
    ecr_mutability      = var.ecr_mutability
    ecr_encryption      = var.ecr_encryption
}

# Task Definition Module
module "task_definition" {
    source               = "./modules/task_definition"
    ecr_image_uri        = module.ecr.ecr_image_uri
    task_exec_name       = var.task_exec_name
    log_group_name       = var.log_group_name
    task_definition_name = var.task_definition_name
    network_mode         = var.network_mode
    launch_type          = var.launch_type
    task_cpu             = var.task_cpu
    task_memory          = var.task_memory
    container_name       = var.container_name 
}

module "ecs" {
    source                    = "./modules/ecs"
    ec2_iam_role_name         = var.ec2_iam_role_name
    ec2_instance_profile_name = var.ec2_instance_profile_name
    instance_type             = var.instance_type
    cluster_name              = var.cluster_name
    service_name              = var.service_name
    private_subnets           = module.vpc.private_subnets
    ec2_security_group_id     = module.vpc.ec2_ecs_sg_id
    task_definition_arn       = module.task_definition.task_definition_arn
    container_name            = module.task_definition.container_name
    target_group_arn          = module.alb.target_group_arn
}

module "alb" {
    source                = "./modules/alb"
    target_type           = var.target_type
    target_group_port     = var.target_group_port
    listener_port         = var.listener_port
    alb_name              = var.alb_name
    lb_type               = var.lb_type
    tg_name               = var.tg_name
    vpc_id                = module.vpc.vpc_id
    public_subnets        = module.vpc.public_subnets
    alb_security_group_id = module.vpc.alb_sg_id
}

module "codebuild" {
    source                 = "./modules/codebuild"
    codebuild_iam_role     = var.codebuild_iam_role
    codebuild_project_name = var.codebuild_project_name
    github_repo_url        = var.github_repo_url
    source_type            = var.source_type
    account_id             = var.account_id
    region                 = var.region
    codebuild_logs         = var.codebuild_logs
    vpc_id                 = module.vpc.vpc_id
    private_subnet_ids     = module.vpc.private_subnets
    private_sg_id          = module.vpc.ec2_ecs_sg_id
    repository_name        = module.ecr.ecr_repository_name
}