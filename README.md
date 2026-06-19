# My DevOps Portfolio

Real-world AWS infrastructure projects from my experience as a Cloud/DevOps/SRE engineer. Each project includes architecture diagrams, Terraform code, and deployment guides. Proprietary details have been removed — feel free to use anything here.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/mrpahlevi)

---

## Tech Stack

| Category | Tools |
|---|---|
| **Container Orchestration** | EKS, ECS Fargate, ECS EC2 |
| **IaC** | Terraform, OpenTofu |
| **CI/CD** | CodePipeline, CodeBuild, CodeDeploy, ArgoCD, Argo Rollouts |
| **Networking** | VPC, Transit Gateway, VPC Endpoints, Site-to-Site VPN, BGP |
| **Observability** | Prometheus, Grafana, CloudWatch Container Insights, ELK Stack |
| **Security** | KMS, WAF, Trivy, IMDSv2, SSM Session Manager, Secrets Manager |
| **DNS & TLS** | Route 53, ACM, Private Hosted Zones |

---

## Projects

| # | Project | Description |
|---|---------|-------------|
| 01 | [Modernize with ECS](#01---modernize-with-ecs) | ECS cluster with blue/green CI/CD — CodePipeline, CodeBuild, Trivy, approval gate |
| 02 | [Centralized VPC Endpoints](#02---centralized-vpc-endpoints) | Shared VPC endpoints across spoke VPCs via Transit Gateway + Route 53 PHZ |
| 03 | [Centralized Egress](#03---centralized-egress) | Single NAT Gateway exit point for multiple VPCs — cost reduction pattern |
| 04 | [Modernize with EKS](#04---modernize-with-eks) | End-to-end EKS: GitOps, ArgoCD blue/green, CI/CD, HPA, Prometheus/Grafana |
| 05 | [Modernize with EKS Fargate](#05---modernize-with-eks-fargate) | Fully serverless EKS — no EC2 node groups |
| 06 | [Speed Up CI/CD](#06---speed-up-cicd) | Terraform provider caching in CodeBuild to cut pipeline runtime and cost |

---

## 01 - Modernize with ECS

![ECS Architecture](./images/ecs-cloudmap.drawio.svg "ECS Cluster Architecture")

![CI/CD Architecture](./images/cicd-ecs-blue-green.drawio.svg "CI/CD Pipeline")

ECS cluster with a full blue/green deployment pipeline using AWS native tooling.

**Pipeline flow:**
1. Developer commits → webhook triggers CodePipeline
2. CodeBuild builds Docker image, pushes to ECR, runs pytest + Trivy security scan
3. Pipeline fails on test or scan failure; on success sends an SNS approval notification
4. After manual approval, CodeDeploy performs blue/green deployment to ECS

**Cluster hardening:**
- ECS Exec via SSM Session Manager, encrypted with KMS
- Container Insights enabled
- WAF attached to the load balancer
- Route 53 + ACM for HTTPS termination

→ [01-modernize-with-ecs/](./01-modernize-with-ecs/)

---

## 02 - Centralized VPC Endpoints

![Centralized VPC Endpoints](./images/centralized-vpce.drawio.svg "Centralized VPC Endpoints")

All AWS service VPC endpoints live in a single hub VPC. Spoke VPCs resolve them via Route 53 Private Hosted Zones, with private DNS resolution disabled at the endpoint level.

**Why it matters:** In a multi-VPC account, you'd normally create the same VPC endpoints in every VPC. This pattern cuts that down to one set — significant cost saving as the number of VPCs grows.

**Design constraints:**
- Endpoint resource policies are capped at 20,480 characters — plan carefully when many VPCs share endpoints
- Endpoint ENIs auto-scale under traffic spikes — allocate enough IP space in the hub VPC

→ [02-centralized-vpce/](./02-centralized-vpce/)

---

## 03 - Centralized Egress

![Centralized Egress](./images/centralized-egress.drawio.svg "Centralized Egress Architecture")

Single NAT Gateway exit point shared across multiple spoke VPCs via Transit Gateway.

**Traffic path:** Spoke VPC → Transit Gateway → Egress VPC → NAT Gateway → Internet Gateway

**Why it matters:** NAT Gateway costs scale with the number of VPCs. This pattern replaces N NAT Gateways with one, which meaningfully reduces cost in environments with many spoke VPCs.

→ [03-centralized-egress/](./03-centralized-egress/)

---

## 04 - Modernize with EKS

![EKS Architecture](./images/eks-architecture.drawio.svg "EKS Architecture")

End-to-end production EKS setup built as 6 progressive stacks, each layered on the previous.

| Stack | What it does |
|---|---|
| `0-baseline` | EKS 1.33, managed node groups (AL2023, gp3, IMDSv2), add-ons, RDS PostgreSQL 17, IAM |
| `1-deploy-apps` | Flask backend + Nginx frontend, Secrets Store CSI Driver, ALB ingress |
| `2-hpa` | Horizontal Pod Autoscaler + Pod Disruption Budget |
| `3-cicd` | CodeCommit → CodePipeline → CodeBuild → ECR → EKS |
| `4-gitops-argocd` | ArgoCD + Argo Rollouts (blue/green) + ArgoCD Image Updater + ECR token refresher CronJob |
| `5-monitoring` | kube-prometheus-stack — Prometheus, Alertmanager, Grafana on gp3 EBS |

→ [04-modernize-with-eks/](./04-modernize-with-eks/)

---

## 05 - Modernize with EKS Fargate

EKS cluster running entirely on AWS Fargate — no EC2 node groups, no node patching, no capacity planning.

- OIDC provider for IRSA
- Fargate profiles for `kube-system`, `coredns`, `default`
- Add-ons configured with `computeType = Fargate`
- CoreDNS Fargate profile must exist before the add-on is applied (ordering handled in Terraform)

→ [05-modernize-with-eks-fargate/](./05-modernize-with-eks-fargate/)

---

## 06 - Speed Up CI/CD

Terraform provider caching in CodeBuild via S3 cache. The `.terraform` directory is cached between pipeline runs so providers and modules are not re-downloaded on every trigger.

**Impact:** Faster pipeline runs and lower data transfer costs — the benefit compounds as the Terraform codebase grows and more providers are used.

**Stack:** GitHub → CodePipeline → CodeBuild (S3 cache)

→ [06-speedup-cicd/](./06-speedup-cicd/)

---

## Reusable Modules

| Module | Description |
|---|---|
| [modules/vpc/](./modules/vpc/) | Full VPC — subnets, route tables, NAT, NACLs, security groups |
| [modules/ecs-task/fargate/](./modules/ecs-task/fargate/) | ECS Fargate task — ECR, task definition, IAM, autoscaling |
| [modules/ecs-task/fargate-cm/](./modules/ecs-task/fargate-cm/) | ECS Fargate task with Cloud Map service discovery |
| [modules/ecs-task/ec2/](./modules/ecs-task/ec2/) | ECS EC2 task — ECR, task definition, load balancer, IAM |
| [modules/codepipeline/](./modules/codepipeline/) | CodePipeline + CodeBuild pipeline |
| [modules/ecs-cicd-ghapps/](./modules/ecs-cicd-ghapps/) | ECS CI/CD pipeline using GitHub Apps source connection |
| [modules/eks/](./modules/eks/) | EKS cluster module |

---

## Archived

Foundational and supporting projects used as building blocks by the projects above.

→ [archived/](./archived/)
