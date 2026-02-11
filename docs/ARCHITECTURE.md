# Application Architecture

This document describes the high-level architecture of the DevSecOps project, including the AWS infrastructure, Kubernetes components, and pipeline security integrations.

## Architecture Diagram

```mermaid
graph TD
    User([User]) -->|HTTPS| ALB[Application LoadBalancer]
    
    subgraph VPC [AWS VPC 10.0.0.0/16]
        subgraph Public_Subnets [Public Subnets]
            ALB
            NAT[NAT Gateway]
        end
        
        subgraph Private_Subnets [Private Subnets]
            EKS_Control[EKS Control Plane]
            
            subgraph EKS_Nodes [EKS Worker Nodes]
                Frontend[Frontend Pods\n(React)]
                Backend[Backend Pods\n(Python Flask)]
                FluentBit[Fluent Bit\n(Logging)]
                CW_Agent[CloudWatch Agent\n(Metrics)]
            end
            
            Redis[ElastiCache Redis]
        end
        
        subgraph Database_Subnets [Database Subnets]
            RDS[RDS PostgreSQL]
        end
    end
    
    Backend -->|Read/Write| RDS
    Backend -->|Cache| Redis
    Frontend -->|API Calls| ALB
    ALB -->|Route traffic| Frontend
    ALB -->|Route traffic| Backend
    
    FluentBit -->|Logs| CW[CloudWatch Logs]
    CW_Agent -->|Metrics| CW
```

## Infrastructure Components

### Network Layer
- **VPC**: Isolated network (`10.0.0.0/16`) hosting all resources.
- **Subnets**: 
  - **Public**: Hosts ALB and NAT Gateways.
  - **Private**: Hosts EKS nodes and ElastiCache.
  - **Database**: Dedicated isolated subnets for RDS.
- **NAT Gateway**: Provides outbound internet access for private resources (e.g., for downloading images/updates).

### Compute Layer (EKS)
- **Cluster**: Amazon EKS (managed Kubernetes).
- **Nodes**: Managed Node Group running in private subnets.
- **Controllers**:
  - **AWS Load Balancer Controller**: Manages ALBs for Ingress.
  - **CloudWatch Agent**: Collects node and container metrics.

### Data Layer
- **PostgreSQL (RDS)**: Primary relational database. Configured with:
  - Multi-AZ availability (optional based on environment).
  - Encryption at rest via KMS.
  - Strictly limited Security Group access (only from EKS nodes).
- **Redis (ElastiCache)**: In-memory caching layer for session management and performance.

## Application Components

1.  **Frontend**:
    - React-based application.
    - Served via Nginx container.
    - Exposed via ALB Ingress.

2.  **Backend**:
    - Python Flask REST API.
    - Connects to RDS and Redis using secrets injected via Environment Variables (or Vault).
    - Exposes API endpoints on port 5000.

## Security & Observability

### Security
- **Identity**: IAM Roles for Service Accounts (IRSA) enforce least privilege for pods (e.g., Fluent Bit, LB Controller).
- **Network**: Security Groups restrict traffic flows (e.g., DB accepts traffic ONLY from App nodes).
- **Secrets**: Managed via AWS Secrets Manager and/or Vault (integrated in backend).

### Observability
- **Logging**: Fluent Bit collects logs from all pods and sends them to **CloudWatch Logs**.
- **Metrics**: CloudWatch Container Insights collects CPU, Memory, and Network metrics.
- **Alerting**: CloudWatch Alarms configured for:
  - Node CPU Utilization > 60%
  - Node Memory Utilization > 60%
