variable "cluster_name" {
  default = "devops-blueprint-eks"
}

variable "region" {
  default = "us-east-1"
}

variable "profile" {
  default = "default"
}

variable "application" {
  type    = string
  default = "devops-blueprint-app"
}

variable "cluster_version" {
  default = "1.25"
}

variable "environment" {
  default = "dev"
}

variable "tfstate_bucket" {
  default = ""
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

