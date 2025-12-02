# Outputs from ECR Module
variable "ecr_image_uri" {
    type = string
}

# Task Definition Variables
variable "task_exec_name" {
    type = string
}

variable "log_group_name" {
    type = string
}

variable "task_definition_name" {
    type = string
}

variable "network_mode" {
    type = string
}

variable "launch_type" {
    type = string
}

variable "task_cpu" {
    type = string
}

variable "task_memory" {
    type = string
}

variable "container_name" {
    type = string
}