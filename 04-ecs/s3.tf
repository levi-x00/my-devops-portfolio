resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_s3_bucket" "s3_sess_manager" {
  force_destroy = true

  bucket = "s3-session-manager-logs-${random_string.random.id}"
  tags = {
    Name = "s3-session-manager-logs-${random_string.random.id}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sess_manager_kms" {
  bucket = aws_s3_bucket.s3_sess_manager.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "sess_manager" {
  bucket = aws_s3_bucket.s3_sess_manager.id
  policy = data.aws_iam_policy_document.s3_sess_manager.json
}

data "aws_iam_policy_document" "s3_sess_manager" {
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
      "arn:aws:s3:::s3-session-manager-logs-${random_string.random.id}",
      "arn:aws:s3:::s3-session-manager-logs-${random_string.random.id}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
