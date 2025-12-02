# Reference from other modules
variable "codebuild_project_arn" {
    type = string
}

variable "codebuild_project_name" {
    type = string
}

variable "ecs_cluster_name" {
    type = string
}

variable "ecs_service_name" {
    type = string
}

# CodePipeline Variables
variable "bucket_name" {
    type = string
}

variable "connection" {
    type = string 
}

variable "provider_type" {
    type = string
}

variable "codepipeline_role_name" {
    type = string
}

variable "pipeline_name" {
    type = string
}

variable "github_repo_url" {
    type = string
}