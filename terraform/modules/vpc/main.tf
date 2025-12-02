# Local Variables
locals {
    public_subnets = {
        Public-Subnet-A = {
            cidr = "192.168.10.0/24"
            az   = "us-east-1a"
        }
        Public-Subnet-B = {
            cidr = "192.168.20.0/24"
            az   = "us-east-1b"
        }
    }
    private_subnets = {
        Private-Subnet-A = {
            cidr = "192.168.30.0/24"
            az   = "us-east-1a"
        }
        Private-Subnet-B = {
            cidr = "192.168.40.0/24"
            az   = "us-east-1b"
        }
    }
    private_to_nat = {
        Private-Subnet-A = "Public-Subnet-A"
        Private-Subnet-B = "Public-Subnet-B"
    }
}

# VPC CIDR
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = var.vpc_name
    }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
    for_each                = local.public_subnets
    vpc_id                  = aws_vpc.vpc.id
    availability_zone       = each.value.az
    cidr_block              = each.value.cidr
    map_public_ip_on_launch = true

    tags = {
        Name = each.key
    }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
    for_each          = local.private_subnets
    vpc_id            = aws_vpc.vpc.id
    availability_zone = each.value.az
    cidr_block        = each.value.cidr

    tags = {
        Name = each.key
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
}

# Elastic IP and NAT Gateway
resource "aws_eip" "eip" {
  for_each = aws_subnet.public_subnet
  domain   = var.eip_domain

  tags = {
    Name = "Nat-EIP-${each.key}"
  }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public_subnet

  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = each.value.id

  tags = { 
    Name = "Nat-GW-${each.key}" 
  }
}

# Public Route Tables
resource "aws_route_table" "public_rt" {
  for_each = aws_subnet.public_subnet
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block = var.public_route_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { 
    Name = "${each.key}-RT" 
  }
}

# Private Route Tables
resource "aws_route_table" "private_rt" {
  for_each = aws_subnet.private_subnet
  vpc_id   = aws_vpc.vpc.id

  tags = { 
    Name = "${each.key}-RT" 
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_rta" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt[each.key].id
}

# Private Route Table Association
resource "aws_route_table_association" "private_rta" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

# Private Route Table NAT Route
resource "aws_route" "private_nat_route" {
  for_each               = aws_subnet.private_subnet
  destination_cidr_block = var.public_route_cidr
  route_table_id         = aws_route_table.private_rt[each.key].id
  nat_gateway_id         = aws_nat_gateway.nat[local.private_to_nat[each.key]].id
}

# ALB Security group
resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "Allows HTTP traffic from the internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

# ECS Security group
resource "aws_security_group" "ec2_ecs_sg" {
  name        = "EC2-ECS-SG"
  description = "Allows Custom TCP traffic on port 5000 (for Flask application) from ALB-SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-ECS-SG"
  }
}