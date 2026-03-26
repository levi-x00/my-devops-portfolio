module "artifacts_bucket" {
  source = "../../modules/s3"

  bucket_name   = "${var.cluster_name}-cicd-artifacts-${local.account_id}"
  force_destroy = true
  versioning    = "Enabled"
  kms_key_arn   = local.kms_key_arn
}
