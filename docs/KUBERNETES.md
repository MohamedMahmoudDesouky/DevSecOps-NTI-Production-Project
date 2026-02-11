# Kubernetes Deployment Guide

This guide details the deployment of the microservices application to the EKS cluster using Helm.

## Prerequisites
- **kubectl** configured with cluster context (`aws eks update-kubeconfig ...`).
- **Helm 3.x** installed.
- **AWS Load Balancer Controller** installed in `kube-system`.

## Helm Charts

The project includes two custom Helm charts located in the `charts/` directory.

### 1. Backend Chart (`charts/backend`)
Deploys the Python Flask API.

**Key Features:**
- **Deployment**: Runs the Flask application container.
- **Service**: Exposed internally on port 80 (target port 5000).
- **ServiceAccount**: Annotated with IAM Role for Vault/AWS access.
- **Vault Integration**: Connects to HashiCorp Vault for secret injection (database credentials).

**Installation:**
```bash
helm upgrade --install backend ./charts/backend \
  --namespace dev \
  --create-namespace \
  --set image.repository=<YOUR_BACKEND_ECR_URI> \
  --set encrypt.secretKey=<YOUR_SECRET_KEY>
```

### 2. Frontend Chart (`charts/frontend`)
Deploys the React Frontend.

**Key Features:**
- **Deployment**: Runs the Nginx container serving React static files.
- **Service**: Type `ClusterIP` on port 80.
- **Ingress**: Uses `AWS Load Balancer Controller` to provision an internet-facing ALB.
- **Wildcard Host**: Configured to accept traffic on the ALB DNS name.

**Installation:**
```bash
helm upgrade --install frontend ./charts/frontend \
  --namespace dev \
  --create-namespace \
  --set image.repository=<YOUR_FRONTEND_ECR_URI>
```

## Traffic Flow
1.  **User** hits ALB DNS Name.
2.  **ALB** routes traffic based on rules (default to Frontend).
3.  **Frontend** pods serve the UI.
4.  **Backend** API calls are routed internally or via ALB paths (if configured) to Backend pods.
