# EKS Module

Terraform module to provision a production-ready Amazon EKS cluster with managed node groups, IAM roles, OIDC provider, EKS add-ons, Cluster Autoscaler, and AWS Load Balancer Controller.

## Features

- EKS cluster with `API_AND_CONFIG_MAP` authentication mode
- Managed node groups with AL2023 AMI via launch template
- Encrypted EBS volumes and secrets via KMS
- OIDC provider for IRSA
- `aws-auth` ConfigMap management for IAM users and roles
- IAM roles for: cluster, node group, CodePipeline CI/CD, Cluster Autoscaler
- EKS add-ons: kube-proxy, CoreDNS, Pod Identity Agent, Metrics Server, EBS CSI Driver
- Helm releases: Cluster Autoscaler, AWS Load Balancer Controller
- CloudWatch Container Insights log groups

## Addon Versions (EKS 1.33)

| Addon | Version |
|---|---|
| kube-proxy | `v1.33.9-eksbuild.2` |
| coredns | `v1.13.2-eksbuild.1` |
| eks-pod-identity-agent | `v1.3.10-eksbuild.2` |
| metrics-server | `v0.8.1-eksbuild.1` |
| aws-ebs-csi-driver | `v1.56.0-eksbuild.1` |
| aws-secrets-store-csi-driver-provider | `v2.2.2-eksbuild.1` |

## Helm Chart Versions

| Chart | Version |
|---|---|
| cluster-autoscaler | `9.43.0` |
| aws-load-balancer-controller | `3.1.0` |
| secrets-store-csi-driver | `1.5.6` |

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name    = "my-eks"
  cluster_version = "1.33"

  vpc_id             = "vpc-xxxxxxxxxxxxxxxxx"
  vpc_cidr_block     = "10.0.0.0/16"
  private_subnet_ids = ["subnet-aaaa", "subnet-bbbb"]
  public_subnet_ids  = ["subnet-cccc", "subnet-dddd"]
  kms_key_arn        = "arn:aws:kms:ap-southeast-1:123456789012:key/xxxxxxxx"

  node_groups = {
    medium = {
      desired_size   = 2
      max_size       = 6
      min_size       = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels         = { Type = "ON_DEMAND" }
    }
  }

  cluster_addons    = ["kube-proxy", "coredns", "eks-pod-identity-agent", "metrics-server"]
  retention_in_days = 30

  map_users = [
    {
      userarn  = "arn:aws:iam::123456789012:user/john"
      username = "john"
      groups   = ["system:masters"]
    }
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::123456789012:role/my-custom-role"
      username = "custom-role"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = "dev"
    Team        = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| `cluster_name` | EKS cluster name | `string` | yes |
| `cluster_version` | Kubernetes version | `string` | yes |
| `vpc_id` | VPC ID | `string` | yes |
| `vpc_cidr_block` | VPC CIDR block | `string` | yes |
| `private_subnet_ids` | Private subnet IDs for nodes | `list(string)` | yes |
| `public_subnet_ids` | Public subnet IDs for public LBs | `list(string)` | yes |
| `kms_key_arn` | KMS key ARN for encryption | `string` | yes |
| `node_groups` | Map of node group configurations | `map(object)` | yes |
| `cluster_addons` | List of EKS addons to install | `list(string)` | no |
| `volume_size` | EBS volume size in GB | `number` | no |
| `volume_type` | EBS volume type | `string` | no |
| `eks_cluster_cidr` | Pod networking CIDR | `string` | no |
| `cluster_dns_ip` | Cluster DNS IP | `string` | no |
| `retention_in_days` | CloudWatch log retention in days | `number` | no |
| `map_users` | IAM users to add to aws-auth | `list(object)` | no |
| `map_roles` | Additional IAM roles to add to aws-auth | `list(object)` | no |
| `tags` | Additional tags for all resources | `map(string)` | no |

## Outputs

| Name | Description |
|---|---|
| `cluster_id` | EKS cluster ID |
| `cluster_arn` | EKS cluster ARN |
| `cluster_endpoint` | EKS API server endpoint |
| `cluster_version` | Kubernetes version |
| `cluster_certificate_authority_data` | Base64 encoded cluster CA |
| `cluster_primary_security_group_id` | Cluster primary security group ID |
| `cluster_iam_role_arn` | EKS cluster IAM role ARN |
| `cluster_oidc_issuer_url` | OIDC issuer URL |
| `openid_connect_provider_arn` | OIDC provider ARN |
| `openid_connect_provider_url` | OIDC provider URL |
| `codepipeline_role_arn` | CodePipeline IAM role ARN |
| `node_role_arn` | Node group IAM role ARN |
| `account_id` | AWS account ID |

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.6.0 |
| aws | >= 6.0 |
| kubernetes | ~> 2.38.0 |
| helm | ~> 3.1.0 |
| http | ~> 3.5.0 |
| tls | ~> 4.0 |
