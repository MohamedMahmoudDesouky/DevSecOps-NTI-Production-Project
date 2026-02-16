DevSecOps Production Project



## 🎯 Main Post



🚀 **Proud to Share: Production-Grade Cloud-Native DevSecOps Infrastructure on AWS**



I'm excited to announce the completion of my comprehensive DevSecOps project - a full-stack, cloud-native application infrastructure that demonstrates enterprise-grade security, automation, and scalability practices.



### 🏗️ **Project Overview**

Built a complete migration from static Kubernetes secrets to a dynamic secret management system using HashiCorp Vault on AWS EKS, implementing a zero-trust security model with automated CI/CD pipelines.



### 🛠️ **Technology Stack**



**Infrastructure & Orchestration:**

- ☁️ AWS (EKS, VPC, RDS PostgreSQL, ElastiCache Redis, EC2)

- 🏗️ Terraform - Infrastructure as Code (30+ modules)

- ⚓ Kubernetes (EKS v1.29) - Container orchestration

- 🎯 Helm Charts - Application deployment

<img width="1024" height="1536" alt="image" src="https://github.com/user-attachments/assets/76d93ae2-4799-41ef-ab67-586d508a58af" />


**Security & Secrets Management:**

- 🔐 HashiCorp Vault - Dynamic secrets management with DynamoDB backend

- 🔑 AWS KMS - Auto-unseal functionality

- 🛡️ Kyverno - Policy-as-Code engine for runtime security

- ✍️ Cosign - Container image signing and verification

- 🔒 Vault Agent Injector - Sidecar-based secret injection



**CI/CD & Automation:**

- 🔄 Azure DevOps Pipelines - Multi-stage deployment (Dev/Staging/Prod)

- 🐳 Docker - Containerization (Backend: FastAPI, Frontend: React)

- 📦 Amazon ECR - Private container registry

- 🤖 Ansible - Configuration management



**Networking & Load Balancing:**

- 🌐 AWS Application Load Balancer (ALB)

- 🔀 AWS Load Balancer Controller

- 🌍 Multi-AZ deployment across 2 availability zones

- 🔒 Network policies for pod-to-pod communication



**Monitoring & Observability:**

- 📊 AWS CloudWatch Container Insights

- 📝 Centralized logging with Fluent Bit

- 🚨 Automated alerting



### 🎯 **Key Achievements**



**1. Zero-Trust Security Model**

- Eliminated static secrets from code and manifests

- Implemented dynamic secret injection via Vault Agent

- Enforced image signature verification with Kyverno policies

- All containers run as non-root with security contexts



**2. Full Infrastructure Automation**

- 100% Infrastructure as Code with Terraform

- Reproducible deployments - entire stack can be provisioned in 20 minutes

- Multi-environment support (Dev, Staging, Production)

- Automated configuration management with Ansible



**3. Secure CI/CD Pipeline**

- 4-stage pipeline: Build → Security Scan → Sign → Deploy

- Trivy vulnerability scanning

- Container image signing with Cosign

- Only signed images can run in cluster (enforced by Kyverno)



**4. Production-Ready Architecture**

- High availability across multiple AZs

- Auto-scaling node groups

- Private subnets for application workloads

- Managed database and cache services (RDS + ElastiCache)



### 🔥 **Complex Problems Solved**



**ISP Traffic Hijacking:** Telecom provider was blocking Vault port 8200 → Established SSH tunnels for secure local access



**Vault-EKS Authentication:** JWT validation failures due to OIDC issuer mismatch → Configured explicit EKS OIDC provider with custom validation settings



**Network Security:** EKS cluster security group blocking Vault token reviews → Added precise ingress rules for Vault-to-EKS communication



**Service Account Permissions:** Vault couldn't verify pod identities → Created dedicated ServiceAccount with `system:auth-delegator` RBAC role



### 📚 **What I Learned**



✅ Advanced Kubernetes security patterns and RBAC

✅ HashiCorp Vault architecture and Kubernetes authentication

✅ Policy-as-Code implementation with Kyverno

✅ Multi-stage CI/CD pipeline design with security gates

✅ AWS networking and security groups in production scenarios

✅ Troubleshooting complex distributed systems

✅ Infrastructure as Code best practices



### 🔧 **Architecture Highlights**



- **Frontend:** React application served via NGINX

- **Backend:** FastAPI application with health checks

- **Database:** RDS PostgreSQL with automated backups

- **Cache:** ElastiCache Redis for session management

- **Secrets:** Vault EC2 instance with DynamoDB storage backend

- **Ingress:** ALB with path-based routing

- **Security:** Multi-layer defense (Network policies, Pod security, Image verification)



### 📊 **By the Numbers**



- 🗄️ 30+ Terraform modules

- ⚓ 34+ Kubernetes manifests

- 🔐 3-stage Vault authentication

- 🛡️ 5+ Kyverno security policies

- 📋 75+ lines of CI/CD pipeline code

- 🌍 2 Availability Zones

- 🔄 3 Environments (Dev/Staging/Prod)


## 📟 List of Key Commands Used

```bash
# Terraform
terraform init && terraform apply -auto-approve
terraform refresh && terraform output -raw vault_public_ip

# Vault Access (SSH Tunnel)
ssh -i ~/.ssh/id_rsa -L 8200:127.0.0.1:8200 ec2-user@<VAULT_IP> -N -f

# Vault Configuration (Local CLI)
export VAULT_ADDR="http://127.0.0.1:8200"
vault secrets enable -path=secret kv-v2
vault write auth/kubernetes/config kubernetes_host=<EKS_ENDPOINT> ...

# Kubernetes
./kubectl apply -f k8s/dev/
./kubectl rollout restart deployment backend -n dev
./kubectl logs <pod> -c vault-agent-init

# Deployment Scripts
./build-and-push.sh v1.0.0
./deploy.sh v1.0.0
```

## 🧹 Cleanup
To destroy all resources:
```bash
terraform destroy -auto-approve
```
