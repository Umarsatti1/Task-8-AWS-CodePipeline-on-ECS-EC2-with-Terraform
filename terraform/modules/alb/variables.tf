# Reference from other modules
variable "vpc_id" {
    type = string 
}

variable "public_subnets" {
    type = any
}

variable "alb_security_group_id" {
    type = string 
}


# ALB Variables
variable "target_group_port" {
    type = number
}

variable "listener_port" {
    type = number
}

variable "target_type" {
    type = string
}

variable "alb_name" {
    type = string
}

variable "lb_type" {
    type = string
}

variable "tg_name" {
    type = string
}