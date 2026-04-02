variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "myapp"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "ics-sandbox"
}

variable "kube_prometheus_stack_version" {
  description = "kube-prometheus-stack Helm chart version"
  type        = string
  default     = "70.4.2"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Prometheus PVC storage size"
  type        = string
  default     = "50Gi"
}

variable "alertmanager_storage_size" {
  description = "Alertmanager PVC storage size"
  type        = string
  default     = "10Gi"
}

variable "grafana_storage_size" {
  description = "Grafana PVC storage size"
  type        = string
  default     = "10Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "tfstate_bucket" {
  description = "S3 bucket for Terraform remote state"
  type        = string
}

variable "network_tfstate_key" {
  description = "S3 key for network stack tfstate"
  type        = string
}

variable "eks_tfstate_key" {
  description = "S3 key for EKS baseline tfstate"
  type        = string
}
