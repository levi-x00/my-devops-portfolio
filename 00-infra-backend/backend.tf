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
  region = var.region

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

resource "aws_dynamodb_table" "dynamodb-lock-table" {
  name           = "dynamodb-lock-table-${random_string.random.id}"
  hash_key       = "LockID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  deletion_protection_enabled = false

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "dynamodb-lock-table-${random_string.random.id}"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket_policy.s3_backend.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.dynamodb-lock-table.id
}
