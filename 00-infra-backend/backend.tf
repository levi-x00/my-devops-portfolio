terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }
  required_version = ">=1.10.0"
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
