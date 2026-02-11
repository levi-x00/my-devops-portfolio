# EKS Baseline Infrastructure

This Terraform configuration provisions a production-ready Amazon EKS cluster with managed node groups, essential add-ons, and security best practices.

## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.6.0 |
| aws | >= 6.0 |
| helm | ~> 3.1.0 |
| http | ~> 3.5.0 |
| kubernetes | ~> 2.38.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0 |
| helm | ~> 3.1.0 |
| http | ~> 3.5.0 |
| kubernetes | ~> 2.38.0 |
| tls | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.container_insights](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_addon.ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amzn_cloudwatch_agent_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_ec2_container_registry_pull_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_block_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_compute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_networking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_vpc_resource_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.amzn_eks_worker_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.cluster_al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [helm_release.aws_secrets_provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.loadbalancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.secrets_store_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.ebs_csi_latest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_addon_version.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_ssm_parameter.eks_al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http.lbc_iam_policy](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [terraform_remote_state.network](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |
| [tls_certificate.cluster](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application | Application name | `string` | `"myapp"` | no |
| aws_profile | AWS CLI profile to use | `string` | `"sandbox"` | no |
| aws_region | AWS region where resources will be created | `string` | `"us-east-1"` | no |
| cluster_addons | List of EKS cluster addons to install | `list(string)` | `["kube-proxy", "coredns", "eks-pod-identity-agent"]` | no |
| cluster_dns_ip | IP address for cluster DNS service | `string` | `"172.20.0.10"` | no |
| cluster_name | EKS cluster name | `string` | `"devops-blueprint-eks"` | no |
| cluster_version | Kubernetes version for EKS cluster | `string` | `"1.33"` | no |
| eks_cluster_cidr | CIDR block for EKS cluster pod networking | `string` | `"172.20.0.0/16"` | no |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| node_groups | Map of EKS node group configurations | `map(object({...}))` | See variables.tf | no |
| retention_in_days | CloudWatch log retention period in days | `number` | `30` | no |
| tfstate_bucket | S3 bucket name for Terraform state | `string` | n/a | yes |
| tfstate_key | S3 key path for Terraform state file | `string` | n/a | yes |
| volume_size | EBS volume size in GB for EKS nodes | `number` | `20` | no |
| volume_type | EBS volume type for EKS nodes | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| account_id | AWS Account ID |
| cluster_arn | EKS cluster ARN |
| cluster_certificate_authority_data | EKS cluster certificate authority data |
| cluster_endpoint | EKS cluster endpoint |
| cluster_iam_role_arn | EKS cluster IAM role ARN |
| cluster_iam_role_name | EKS cluster IAM role name |
| cluster_id | EKS cluster ID |
| cluster_oidc_issuer_url | EKS cluster OIDC issuer URL |
| cluster_primary_security_group_id | EKS cluster primary security group ID |
| cluster_version | EKS cluster Kubernetes version |
| cluster_vpc_id | VPC ID where EKS cluster is deployed |
| openid_connect_provider_cluster_arn | OIDC provider ARN |
| openid_connect_provider_cluster_url | OIDC provider URL |

## Features

- **EKS Cluster**: Kubernetes 1.33 with API and ConfigMap authentication
- **Managed Node Groups**: Multiple node groups with auto-scaling support
- **Security**: 
  - Encrypted EBS volumes with KMS
  - Secrets encryption at rest
  - IMDSv2 required
  - Private subnets deployment
- **Observability**: 
  - CloudWatch Container Insights
  - Control plane logging enabled
- **Add-ons**:
  - AWS EBS CSI Driver
  - AWS Load Balancer Controller
  - Secrets Store CSI Driver
  - Core DNS, kube-proxy, Pod Identity Agent
- **Custom User Data**: AL2023 optimized AMI with custom bootstrap configuration

## Usage

```bash
# Initialize Terraform
terraform init -backend-config=backend.config

# Plan changes
terraform plan

# Apply configuration
terraform apply

# Update kubeconfig
aws eks update-kubeconfig --name devops-blueprint-eks --region us-east-1 --profile sandbox
```
