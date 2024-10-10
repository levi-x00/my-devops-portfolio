resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  lower   = true
  numeric = true
}

######################## s3 bucket artifact #########################
resource "aws_s3_bucket" "s3_artifact" {
  force_destroy = true

  bucket = "s3-artifact-${random_string.random.id}"
  tags = {
    Name = "s3-artifact-${random_string.random.id}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_artifact" {
  bucket = aws_s3_bucket.s3_artifact.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "artifact" {
  bucket = aws_s3_bucket.s3_artifact.id
  policy = data.aws_iam_policy_document.s3_artifact.json
}

data "aws_iam_policy_document" "s3_artifact" {
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
      "arn:aws:s3:::s3-artifact-${random_string.random.id}",
      "arn:aws:s3:::s3-artifact-${random_string.random.id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
