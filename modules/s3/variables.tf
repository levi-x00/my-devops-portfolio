variable "bucket_name" {}
variable "force_destroy" {}
variable "versioning" {
  default = "Disabled"
}
variable "bucket_policy" {
  default = null
}
