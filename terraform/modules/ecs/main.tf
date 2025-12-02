data "aws_ami" "ecs_optimized_al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-x86_64"]
  }
}

# IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_instance_role" {
  name = var.ec2_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { 
        Service = "ec2.amazonaws.com" 
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policies attached to the EC2 IAM Role
resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.ec2_instance_profile_name
  role = aws_iam_role.ec2_instance_role.name
}

# Launch Template
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-lt-"
  image_id      = data.aws_ami.ecs_optimized_al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    security_groups = [var.ec2_security_group_id]
  }
  
  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name                  = "${var.cluster_name}-asg"
  min_size              = 2
  max_size              = 2
  desired_capacity      = 2
  vpc_zone_identifier   = var.private_subnets
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "${var.cluster_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs_cp.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
    weight            = 1
    base              = 0
  }
}

# ECS Service
resource "aws_ecs_service" "service" {
  name                               = var.service_name
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = var.task_definition_arn
  desired_count                      = 2
  launch_type                        = "EC2"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = 5000
  }
}