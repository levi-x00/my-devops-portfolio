resource "aws_s3_bucket" "s3_artf" {
  bucket = "s3-artf-bucket"

  tags = {
    Name = "s3-artf-bucket"
  }
}

data "aws_iam_policy_document" "s3_artf_policy" {
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
      "arn:aws:s3:::s3-artf-bucket",
      "arn:aws:s3:::s3-artf-bucket/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_artf_acl" {
  bucket = aws_s3_bucket.s3_artf.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
