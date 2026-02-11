# Monitoring & Observability Guide

This project utilizes a cloud-native monitoring stack powered by **AWS CloudWatch**, integrated directly with Amazon EKS.

## Overview
- **Metrics**: Amazon CloudWatch Container Insights.
- **Logging**: Fluent Bit (sending logs to CloudWatch Logs).
- **Alerting**: CloudWatch Alarms + SNS Notifications.

## 1. Metrics Collection
We use the **CloudWatch Observability Add-on** (Amazon CloudWatch Agent) to collect metrics.

- **Agent**: Deployed as a DaemonSet (`amazon-cloudwatch-observability`).
- **Collected Metrics**:
  - **Cluster**: Node status, pod status, namespace usage.
  - **Node**: CPU utilization, Memory utilization, Disk I/O, Network I/O.
  - **Pod**: CPU usage, Memory usage.

**Dashboard**:
Metrics are automatically visualized in the AWS Console under **CloudWatch > Container Insights** or **CloudWatch > Insights > Performance Monitoring**.

## 2. Log Aggregation
We use **Fluent Bit** to aggregate logs from all pods and shipping them to CloudWatch Logs.

- **Agent**: Deployed as a DaemonSet (`aws-for-fluent-bit`).
- **Log Groups**:
  - `/aws/eks/capstone-project/cluster`: Control plane logs (API, Audit, Authenticator).
  - `/aws/containerinsights/capstone-project/application`: Application logs from pods.
  - `/aws/containerinsights/capstone-project/host`: Node system logs.
  - `/aws/containerinsights/capstone-project/dataplane`: EKS data plane logs.

**Querying Logs**:
Use **CloudWatch Logs Insights** to query application logs:
```sql
fields @timestamp, @message
| sort @timestamp desc
| limit 20
```

## 3. Alerting Strategy
Alerts are configured to notify the operations team via email (SNS).

### Configured Alarms
| Alarm Name | Metric | Threshold | Duration | Action |
|------------|--------|-----------|----------|--------|
| `EKS-Node-CPU-High` | `node_cpu_utilization` | > 60% | 10 min (2 periods) | Notify SNS `eks-nodes-alerts` |
| `EKS-Node-Memory-High` | `node_memory_utilization` | > 60% | 10 min (2 periods) | Notify SNS `eks-nodes-alerts` |

### Notification Channel
- **SNS Topic**: `eks-nodes-alerts`
- **Subscription**: Email (confirmed by user).

## Comparison with Alternative Options

While **CloudWatch** was chosen for its native integration and simplicity, the architecture supports alternative stacks mentioned in the project requirements:

- **Prometheus/Grafana**: not deployed. To implement, install `kube-prometheus-stack` helm chart.
- **ELK Stack**: not deployed. To implement, configure Fluent Bit to output to Elasticsearch instead of CloudWatch.
