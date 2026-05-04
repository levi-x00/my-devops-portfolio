terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">=1.14.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.environment
      Application = var.application
    }
  }
}

resource "aws_s3_bucket" "s3_backend" {
  force_destroy = true

  bucket = "s3-backend-tfstate-${random_string.random.id}"

  tags = {
    Name = "s3-backend-tfstate-${random_string.random.id}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backend" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.kms.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "s3_backend" {
  bucket = aws_s3_bucket.s3_backend.id
  policy = data.aws_iam_policy_document.s3_backend.json
}

resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  lower   = true
  numeric = true
}

data "aws_iam_policy_document" "s3_backend" {
  statement {
    sid = "AllowSSLRequestsOnly"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Deny"
    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::s3-backend-tfstate-${random_string.random.id}",
      "arn:aws:s3:::s3-backend-tfstate-${random_string.random.id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket_policy.s3_backend.id
}
