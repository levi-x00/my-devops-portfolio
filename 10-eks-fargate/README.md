# 10-eks-fargate

EKS cluster running entirely on AWS Fargate — no EC2 node groups.

## Resources

- EKS cluster (public endpoint)
- IAM role for EKS control plane
- IAM role for Fargate pod execution
- OIDC provider for IRSA
- Fargate profiles: `kube-system`, `coredns`, `default`
- Add-ons: `vpc-cni`, `kube-proxy`, `coredns` (Fargate compute type)

## Prerequisites

- Network stack deployed with remote state in S3

## Usage

```bash
terraform init -backend-config=backend.config
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Notes

- CoreDNS add-on uses `computeType = Fargate` — requires the coredns Fargate profile to exist first
- No `backend.config` or `terraform.tfvars` are committed — create them locally before running
