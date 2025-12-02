variable "ec2_iam_role_name" {
    type = string
}

variable "ec2_instance_profile_name" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "service_name" {
    type = string
}

# Reference Variables from other modules
variable "ec2_security_group_id" {
    type = string
}

variable "private_subnets" {
    type = any
}

variable "task_definition_arn" {
    type = string
}

variable "container_name" {
    type = string
}

variable "target_group_arn" {
    type = string
}