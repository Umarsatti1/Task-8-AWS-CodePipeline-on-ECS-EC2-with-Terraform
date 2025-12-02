# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = var.codebuild_iam_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { 
        Service = "codebuild.amazonaws.com" 
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# CloudWatch Logs Policy
resource "aws_iam_role_policy" "logs_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# S3 Policy
resource "aws_iam_role_policy" "s3_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetEncryptionConfiguration"
      ]
      Resource = "*"
    }]
  })
}

# ECR Policy
resource "aws_iam_role_policy" "ecr_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
        
      ]
      Resource = "*"
    }]
  })
}

# VPC Policy
resource "aws_iam_role_policy" "vpc_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_codebuild_project" "flask_project" {
    name         = var.codebuild_project_name
    description  = "Python flask CodeBuild Project for CI/CD"
    service_role = aws_iam_role.codebuild_role.arn

    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_MEDIUM"
        image                       = "aws/codebuild/amazonlinux-x86_64-standard:5.0"
        type                        = "LINUX_CONTAINER"
        privileged_mode             = true
        image_pull_credentials_type = "CODEBUILD"

        environment_variable {
            name  = "ACCOUNT_ID"
            value = var.account_id
            type  = "PLAINTEXT"
        }

        environment_variable {
            name  = "REGION"
            value = var.region
            type  = "PLAINTEXT"
        }

        environment_variable {
            name  = "REPOSITORY_NAME"
            value = var.repository_name
            type  = "PLAINTEXT"
        }
    }

    logs_config {
      cloudwatch_logs {
        group_name = var.codebuild_logs
      }
    }

    source {
        type            = var.source_type
        location        = var.github_repo_url
        auth {
            type     = "OAUTH"
            resource = "arn:aws:codestar-connections:us-east-1:${var.account_id}:connection/aws-github-connection"
        }
        git_clone_depth = 1

        git_submodules_config {
            fetch_submodules = true
        }
    }

    source_version = "main"

    vpc_config {
        vpc_id             = var.vpc_id
        subnets            = var.private_subnet_ids
        security_group_ids = [var.private_sg_id]
    }
}