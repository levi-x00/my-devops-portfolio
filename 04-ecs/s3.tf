resource "random_string" "random" {
  length  = 7
  special = false
  upper   = false
  lower   = true
  numeric = true
}

#------------------------------------------------------------------------------------------------------
# s3 for session manager logs into fargate
#------------------------------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------------------------------
# s3 bucket for artifact ci/cd pipelines for services in ECS
#------------------------------------------------------------------------------------------------------
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


resource "aws_s3_bucket" "s3_lb_logs" {
  force_destroy = true

  bucket = "s3-lb-logs-${random_string.random.id}"
  tags = {
    Name = "s3-lb-logs-${random_string.random.id}"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_lb_logs" {
  bucket = aws_s3_bucket.s3_lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = local.kms_key_arn
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "s3_lb_logs" {
  bucket = aws_s3_bucket.s3_lb_logs.id
  policy = data.aws_iam_policy_document.s3_lb_logs.json
}

data "aws_iam_policy_document" "s3_lb_logs" {
  statement {
    sid = "AllowLBAccessLogs"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_elb_service_account.lb.arn
      ]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::s3-lb-logs-${random_string.random.id}/*",
      "arn:aws:s3:::s3-lb-logs-${random_string.random.id}/${var.cluster_name}-public-alb/AWSLogs/${local.account_id}/*",
      "arn:aws:s3:::s3-lb-logs-${random_string.random.id}/${var.cluster_name}-internal-alb/AWSLogs/${local.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }

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
      "arn:aws:s3:::s3-lb-logs-${random_string.random.id}",
      "arn:aws:s3:::s3-lb-logs-${random_string.random.id}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
