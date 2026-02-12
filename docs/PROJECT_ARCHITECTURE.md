# Project Architecture & Documentation

This document provides a detailed explanation of the DevSecOps-NTI-Production-Project codebase, covering infrastructure, security, kubernetes, and CI/CD pipelines.

## 1. Repository Structure Overview

The repository is organized into logical components separating infrastructure, application code, and operational configuration.

```
├── ansible/                # Config management for Vault & Security extensions
├── backend/                # Python/Flask Backend Application
├── charts/                 # Helm Charts for Kubernetes deployments
├── devops/                 # CI/CD Templates & Scripts
├── docs/                   # Documentation (Guides, Setup, Terraform)
├── frontend/               # Node.js/React Frontend Application
├── k8s/                    # Raw Kubernetes Manifests & Kyverno Policies
├── terraform/              # Infrastructure as Code (AWS Resource Provisioning)
├── azure-pipelines-*.yml   # CI/CD Pipeline Definitions
```

## 2. Infrastructure (Terraform) (`/terraform`)

The project uses modular Terraform to provision a secure AWS environment.

### Core Modules
*   **VPC (`modules/vpc`)**: Creates the network foundation.
    *   Public Subnets: For Load Balancers (ALB).
    *   Private Subnets: For EKS Nodes (Worker Nodes).
    *   Database Subnets: Isolated networks for RDS and Redis.
*   **EKS (`modules/eks`)**: Provisions the Kubernetes Control Plane and Worker Node Groups (instances managed by ASG).
*   **Security (`modules/security`)**: Manages KMS Keys (Encryption) and Security Groups (Firewalls) for RDS/Redis/EKS.
*   **RDS (`modules/rds`)**: Deploys a managed Postgres database in private subnets, encrypted with KMS.
*   **Redis (`modules/redis`)**: Deploys ElastiCache Redis for caching, encrypted with KMS.
*   **ECR (`modules/ecr`)**: Creates detailed Container Registries with lifecycle policies and scan-on-push enabled.

### State Management
*   **Backend (`backend.tf`)**: Stores state in S3 (`capstone-tf-state...`) with DynamoDB locking (`terraform-lock`) to prevent concurrent edits.

## 3. Kubernetes & Security (`/k8s`, `/charts`)

### Governance (Kyverno)
Located in `k8s/kyverno/policies/`.
*   **`require-non-root.yaml`**: Enforces best practices by blocking containers running as root (UID 0), reducing attack surface.
*   **`verify-images.yaml`**: INTEGRITY CHECK. Ensures only images signed by your specific Cosign keys (or OIDC identity) can run in the cluster.

### Access Management (Vault)
Located in `ansible/` and `terraform/modules/vault` (commented out in main).
*   **Integration**: Vault tracks secrets (DB passwords) and injects them safely into Pods at runtime using the Vault Agent Injector.
*   **Authorization**: Uses Kubernetes Auth Method (`ansible/vault-config.yml`) to bind K8s Service Accounts to Vault Roles.

### Deployment (Helm Charts)
*   **Backend (`charts/backend`)**: Deployment, Service, and Vault annotation injection for the Python app.
*   **Frontend (`charts/frontend`)**: Deployment, Service, and Ingress (ALB) configuration for the Node.js app.

## 4. CI/CD Pipelines (Azure DevOps)

The system relies on three primary pipelines.

### `azure-pipelines-infra.yml` (Infrastructure)
1.  **Security Scan**: Runs `Trivy` on Terraform code to find misconfigurations (public buckets, unencrypted disks).
2.  **Diagnostics**: Checks AWS connectivity and State bucket access.
3.  **Terraform Lifecycle**: Init -> Validate -> Plan -> Apply. *
    *   *Note: We recently patched the Init step to ensure failures break the pipeline correctly.*
4.  **Post-Provisioning**: Installs Kyverno (Policy Engine) and Vault Injector into the cluster.

### `azure-pipelines-backend.yml` & `azure-pipelines-frontend.yml`
1.  **Build**: Creates Docker image.
2.  **Security Checks**:
    *   **Trivy**: Scans the *image* for OS vulnerabilities.
    *   **Syft**: Generates an SBOM (Software Bill of Materials).
    *   **Cosign**: Signs the image to ensure integrity (checked later by Kyverno).
3.  **Publish**: Pushes to AWS ECR.
4.  **Deploy**: Uses Helm to deploy the new image to the EKS Dev environment.

## 5. Key Operational Files
*   **`ansible/vault-config.yml`**: Playbook to configure Vault completely (enable engines, auth methods, policies) in one go.
*   **`devops/templates/*.yml`**: Reusable pipeline steps (Verify, Build, Deploy) to keep main pipelines clean.
