variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for public load balancers"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "cluster_addons" {
  description = "List of EKS cluster addons to install"
  type        = list(string)
  default     = ["kube-proxy", "coredns", "eks-pod-identity-agent", "metrics-server"]
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

variable "ami_release_version" {
  description = "AMI release version for EKS nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
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
}

variable "retention_in_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
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

variable "map_roles" {
  description = "Additional IAM roles to grant access to the EKS cluster"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
