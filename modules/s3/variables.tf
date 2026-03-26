variable "bucket_name" {}
variable "force_destroy" {}
variable "versioning" {
  default = "Disabled"
}
variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption. If not provided, encryption is not configured."
  type        = string
  default     = null
}
variable "bucket_policy" {
  default = null
}
