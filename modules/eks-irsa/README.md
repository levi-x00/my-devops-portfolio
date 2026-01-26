# EKS IRSA Module

Terraform module to create IAM Role for Service Account (IRSA) using EKS Pod Identity.

## Usage

```hcl
module "s3_reader_irsa" {
  source = "./modules/eks-irsa"

  role_name       = "my-app-s3-reader"
  cluster_name    = "my-eks-cluster"
  namespace       = "default"
  service_account = "my-app-sa"

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Environment = "dev"
    Application = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| role_name | IAM role name for service account | string | - | yes |
| cluster_name | EKS cluster name | string | - | yes |
| namespace | Kubernetes namespace | string | - | yes |
| service_account | Kubernetes service account name | string | - | yes |
| policy_arns | List of IAM policy ARNs to attach | list(string) | [] | no |
| tags | Tags to apply to IAM role | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the IAM role |
| role_name | Name of the IAM role |
| pod_identity_association_id | ID of the pod identity association |
