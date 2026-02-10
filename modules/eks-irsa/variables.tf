variable "role_name" {
  description = "IAM role name for service account"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_policy_json" {
  description = "Custom IAM policy JSON to create and attach to the role"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to IAM role"
  type        = map(string)
  default     = {}
}
