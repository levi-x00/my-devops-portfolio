variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "sandbox"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-blueprint-eks"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.33"
}

variable "cluster_addons" {
  description = "List of EKS cluster addons to install"
  type        = list(string)
  default     = ["kube-proxy", "coredns", "eks-pod-identity-agent", "metrics-server"]
}

variable "retention_in_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "volume_size" {
  description = "EBS volume size in GB for EKS nodes"
  type        = number
  default     = 20
}

variable "volume_type" {
  description = "EBS volume type for EKS nodes"
  type        = string
  default     = "gp3"
}

variable "eks_cluster_cidr" {
  description = "CIDR block for EKS cluster pod networking"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_dns_ip" {
  description = "IP address for cluster DNS service"
  type        = string
  default     = "172.20.0.10"
}

variable "node_groups" {
  description = "Map of EKS node group configurations"
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
  }))
  default = {
    medium = {
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels         = { Type = "ON_DEMAND" }
    }
  }
}

variable "tfstate_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "tfstate_key" {
  description = "S3 key path for Terraform state file"
  type        = string
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL. If empty, a random password is generated."
  type        = string
  sensitive   = true
  default     = ""
}

variable "map_users" {
  description = "List of IAM users to grant access to the EKS cluster"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
