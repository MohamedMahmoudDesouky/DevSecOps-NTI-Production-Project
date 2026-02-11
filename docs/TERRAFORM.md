# Terraform Infrastructure Documentation

This document details the Terraform configuration used to provision the AWS infrastructure for the project.

## Project Structure

```bash
terraform/
├── main.tf             # Root module orchestrating all child modules
├── variables.tf        # Input variables for the root module
├── outputs.tf          # Output values useful for deployment (e.g., ECR URLs, RDS endpoint)
├── backend.tf          # Remote state configuration (S3 + DynamoDB)
├── providers.tf        # AWS provider configuration
└── modules/            # Reusable infrastructure components
    ├── vpc             # Networking (VPC, Subnets, IGW, NAT)
    ├── eks             # Kubernetes Cluster, Node Groups, IRSA
    ├── rds             # PostgreSQL Database
    ├── redis           # ElastiCache Redis Cluster
    ├── alb             # Application Load Balancer
    ├── ecr             # Container Registries
    └── security        # KMS Keys, Random Passwords
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `aws_region` | AWS region for deployment | `string` | `"us-east-2"` | no |
| `project_name` | Project name used for resource naming and tagging | `string` | `"capstone-project"` | no |
| `vpc_cidr` | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |
| `db_password` | Database master password (if empty, auto-generated) | `string` | `""` | no |
| `ssh_public_key_path` | Path to the SSH public key for EKS nodes | `string` | `"~/.ssh/id_rsa.pub"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_name` | Name of the EKS cluster |
| `cluster_endpoint` | Endpoint API URL for the EKS cluster |
| `alb_dns_name` | DNS name of the Application Load Balancer |
| `rds_endpoint` | Connection endpoint for the RDS PostgreSQL instance |
| `redis_endpoint` | Connection endpoint for the ElastiCache Redis cluster |
| `backend_ecr_url` | ECR repository URL for the backend application |
| `frontend_ecr_url` | ECR repository URL for the frontend application |
| `node_security_group_id` | Security Group ID for EKS nodes (useful for allow-listing) |
| `cluster_oidc_issuer_url` | OIDC Issuer URL for configuring IRSA |
