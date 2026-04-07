# EKS

## Infrastructure Architecture

![EKS Architecture](../images/eks-architecture.drawio.svg?raw=true "EKS Architecture")

## Overview

End-to-end EKS setup broken into 5 progressive stacks:

| Stack | Description |
|---|---|
| `0-baseline` | EKS cluster, managed node groups, add-ons, RDS PostgreSQL, IAM roles |
| `1-deploy-apps` | Flask backend + Nginx frontend deployed via K8s manifests |
| `2-hpa` | Horizontal Pod Autoscaler + Pod Disruption Budget |
| `3-cicd` | CodeCommit → CodePipeline → CodeBuild → ECR → EKS |
| `4-gitops-argocd` | ArgoCD + Argo Rollouts (blue/green) + ArgoCD Image Updater |
| `5-monitoring` | Prometheus + Grafana via kube-prometheus-stack |

## Prerequisites

- `01-network-stack` applied (VPC, subnets, KMS key, NAT gateway)
- S3 backend for Terraform state (`00-infra-backend`)
- AWS CLI configured with appropriate profile

## How Setup

After the VPC is already set up from `01-network-stack`, modify `0-baseline/backend.config` and `0-baseline/data.tf`. Replace the unique code:

```terraform
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-<unique-code>"
    key    = "dev/network.tfstate"
    region = var.region
  }
}
```

Replace the unique code and the region in `0-baseline/provider.tf`:

```terraform
terraform {
  backend "s3" {
    bucket       = "s3-backend-tfstate-<unique-code>"
    key          = "dev/eks-stack.tfstate"
    region       = "<region>"
    encrypt      = true
    use_lockfile = true
  }
}
```

Once done, run the following commands:

```sh
# Terraform
terraform init -backend-config=backend.config
terraform plan
terraform apply -auto-approve

# OpenTofu
tofu init -backend-config=backend.config
tofu plan
tofu apply -auto-approve
```

After the cluster is up, update your kubeconfig:

```sh
aws eks update-kubeconfig --name <cluster-name> --region <region> --profile <profile>
```

## Stack Details

### 0-baseline — EKS Cluster

Provisions the core infrastructure:

- **EKS Cluster** — Kubernetes 1.33, private subnets, API + ConfigMap auth
- **Managed Node Groups** — AL2023 AMI, gp3 EBS, IMDSv2, auto-scaling
- **Add-ons** — kube-proxy, coredns, eks-pod-identity-agent, metrics-server, aws-ebs-csi-driver, aws-secrets-store-csi-driver-provider
- **Helm** — AWS Load Balancer Controller, Secrets Store CSI Driver, Cluster Autoscaler
- **RDS PostgreSQL 17** — private subnet, encrypted, credentials stored in Secrets Manager
- **IAM** — CodeBuild role (EKS access), backend Pod Identity role (Secrets Manager + S3)
- **CloudWatch** — Container Insights, control plane logs

### 1-deploy-apps — CRUD Application

Simple frontend + backend app:

- **Backend** — Flask API, reads DB credentials from Secrets Manager via CSI Driver
- **Frontend** — Nginx serving static JS, proxies `/api/` to backend ClusterIP
- **Ingress** — ALB via AWS Load Balancer Controller (internet-facing)
- **Secrets** — injected via `SecretProviderClass` (Secrets Store CSI Driver)

### 2-hpa — Autoscaling

- **HPA** — scales backend and frontend pods based on CPU utilization (target 50%)
- **PDB** — ensures minimum pod availability during voluntary disruptions

### 3-cicd — CI/CD Pipeline

- **CodeCommit** — separate repos for backend and frontend
- **CodePipeline** — Source → Build per service, triggered by EventBridge
- **CodeBuild** — builds Docker image, pushes to ECR, deploys to EKS via `kubectl`
- **S3** — encrypted artifacts bucket (KMS)

### 4-gitops-argocd — GitOps

- **ArgoCD** — syncs K8s manifests from CodeCommit repos
- **Argo Rollouts** — blue/green deployments with manual promotion
- **ArgoCD Image Updater** — polls ECR every 2 min, updates image tag in repo
- **ECR Token Refresher** — CronJob refreshes ECR credentials every 6h
- **Pod Identity** — ArgoCD repo-server (CodeCommit), Image Updater (ECR)

### 5-monitoring — Observability

- **kube-prometheus-stack** — Prometheus, Alertmanager, Grafana
- **Persistence** — gp3 EBS volumes (50Gi Prometheus, 10Gi Alertmanager, 10Gi Grafana)
- **node-exporter** — DaemonSet for node-level metrics
- **kube-state-metrics** — Kubernetes object metrics
- **Access** — port-forward or internal ALB ingress
