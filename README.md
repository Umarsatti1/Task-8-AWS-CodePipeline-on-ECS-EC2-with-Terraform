# TASK 8: Deploying an Application using AWS CodePipeline on ECS EC2 with Terraform

---

## Task Description

This project demonstrates a full CI/CD flow that builds, stores, and deploys a Python **Flask** web application using **AWS CodePipeline → CodeBuild → ECR → ECS (EC2 launch type)** with infrastructure provisioned by **Terraform**. Key features:

- A fully isolated AWS VPC with 4 subnets (2 public, 2 private).  
- NAT Gateways for private subnet egress.
- ECS Cluster and EC2 Auto Scaling Group managed by ECS Capacity Providers.
- ECR Repository for container artifacts.
- ALB directing traffic to ECS tasks. 
- CodeBuild project to build Docker images in a VPC. 
- CodePipeline for Source → Build → Deploy stages.

---

## Architecture Diagram

<p align="center">
  <img src="./diagram/Architecture Diagram.png" alt="Architecture Diagram" width="850">
</p>

---

## Project Files & Structure

    project/
    │
    │   app.py
    │   Dockerfile
    │   requirements.txt
    │
    └── terraform/
        │   main.tf
        │   terraform.tf
        │   variables.tf
        │   terraform.tfvars
        │   outputs.tf
        │
        └── modules/
            ├── vpc/
            ├── ecr/
            ├── task_definition/
            ├── ecs/
            ├── alb/
            ├── codebuild/
            └── codepipeline/

Terraform root directory contains:

- `terraform.tf` — provider and backend S3 configuration.  
- `main.tf` — root orchestrator that loads all modules.  
- `variables.tf` — root variables.  
- `terraform.tfvars` — environment-specific values.  
- `outputs.tf` — root outputs.  
- `modules/` — module subdirectories: `vpc`, `ecr`, `task_definition`, `ecs`, `alb`, `codebuild`, `codepipeline`.

---

## Terraform Structure & Root Files

**terraform.tf**
- Declares AWS provider (hashicorp/aws) and backend S3 for remote state.
- Enables `use_lockfile = true` to prevent concurrent state operations.

**main.tf (root)**
- Loads modules in dependency order: VPC → ECR → Task Definition → ALB → ECS → CodeBuild → CodePipeline.
- Wires module outputs (subnets, security groups, ECR URI, TG ARN) between modules.

**variables.tf / terraform.tfvars**
- Parameterize environment-specific settings (VPC CIDR, names, instance types, repo names, pipeline settings).

**outputs.tf**
- Exposes useful values like `alb_dns_name`.

---

## Modules

### VPC Module
- Creates VPC with DNS support and hostnames enabled.
- Defines public + private subnets via `locals` maps; creates one NAT Gateway + EIP per public subnet for AZ-level redundancy.
- Route tables: public RT routes to IGW; private route tables route to NATs.
- Security groups:
  - `ALB-SG`: allows HTTP (80) from 0.0.0.0/0.
  - `EC2-ECS-SG`: allows ingress from ALB-SG on port **5000** and ephemeral ports for health checks.

**Outputs:** `vpc_id`, `public_subnets`, `private_subnets`, `alb_sg_id`, `ec2_ecs_sg_id`.

---

### ECR Module
- Creates an ECR repository with configurable mutability and encryption.
- `force_delete = true` for easier cleanup during development.
**Outputs:** `ecr_image_uri`, `ecr_repository_name`.

---

### Task Definition Module
- Creates IAM role for task execution and attaches `AmazonECSTaskExecutionRolePolicy`.
- CloudWatch log group with 7-day retention.
- ECS Task Definition using `ecr_image_uri:latest`, exposes container port 5000, configures awslogs driver.

**Outputs:** `task_definition_arn`, `container_name`.

---

### ECS Module
- Looks up latest ECS-optimized AL2023 AMI.
- Creates EC2 IAM role + instance profile, attaches ECS and SSM managed policies.
- Launch Template (user-data sets `ECS_CLUSTER`) and Auto Scaling Group (2 instances).
- ECS Cluster with container insights and ECS Exec enabled.
- Capacity provider tying ASG to ECS and enabling managed scaling.
- ECS Service (EC2 launch type), desired count 2, registers tasks to ALB target group on port **5000**.

**Outputs:** `ecs_cluster_name`, `ecs_service_name`.

---

### ALB Module
- Internet-facing ALB deployed across public subnets.
- Target group (configurable `target_type`, typically `instance` for EC2) listening on specified `target_group_port`.
- Listener on `listener_port` (typically 80) forwards to target group.

**Outputs:** `alb_arn`, `target_group_arn`, `alb_dns_name`.

---

### CodeBuild Module
- IAM role with inline policies for CloudWatch Logs, S3, ECR, and VPC network interface permissions.
- CodeBuild project configured with privileged Docker build (`privileged_mode = true`) and environment variables (`ACCOUNT_ID`, `REGION`, `REPOSITORY_NAME`).
- Runs inside the private subnets with provided security group.
- Uses **buildspec.yml** file stored in root directory.

**Outputs:** `codebuild_project_arn`, `codebuild_project_name`.

---

### CodePipeline Module
- S3 artifact bucket (blocked public access) for pipeline artifacts.
- CodeStar GitHub connection to your repo (`github_repo_url`).
- IAM role and policy that allows S3, CodeBuild start, CodeStar connection use, and ECS actions (requires `iam:PassRole`).
- Pipeline with stages:
  1. **Source**: CodeStarSourceConnection (GitHub) — outputs `SourceArtifact`.
  2. **Build**: CodeBuild — outputs `BuildArtifact`.
  3. **Deploy**: ECS — uses `imagedefinitions.json` to update ECS service.

---

## Deployment Steps (Terraform)

> **Pre-req:** Configure AWS credentials and be in the project root where `terraform.tf` and root `main.tf` reside.

```bash
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```

Expected results:
- Terraform provisions VPC, ALB, ECR, ECS (ASG + cluster), CodeBuild, and CodePipeline.
- State file stored in S3 backend (e.g., `umarsatti-terraform-state-file-s3-bucket/Task-8/terraform.tfstate`).

---

## Deploy via CodePipeline (CI/CD)

1. Push your code to the GitHub repo linked in the CodeStar connection.
2. In CodePipeline, **Release change** (manually trigger) or push a commit to `main`.
3. Pipeline steps:
   - Source: fetch from GitHub.
   - Build: CodeBuild builds Docker image, pushes to ECR, creates `imagedefinitions.json`.
   - Deploy: ECS action updates the service with the new image.

**Note:** If the CodeStar connection is **inactive**, manually click **Update Connection** in AWS console or re-establish OAuth.

---

## Verification — Confirm Application is Accessible

1. Navigate to **EC2 → Load Balancers** and copy ALB DNS name.  
2. Open browser to the ALB DNS — you should see the Flask page:  

> "Deploying an Application using AWS CodePipeline on ECS EC2 with Terraform"

3. In **ECS → Clusters → <cluster> → Services**, confirm tasks are running (2/2) and target group shows healthy targets.

---

## Clean Up

To destroy all resources:

```bash
terraform destroy --auto-approve
```

This will remove VPC, Subnets, Security groups, ECS resources, ALB, ECR, CodeBuild, CodePipeline, and the S3 backend bucket (if managed by your Terraform configuration).

---