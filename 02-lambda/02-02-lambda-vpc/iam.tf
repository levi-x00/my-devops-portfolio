# this can modified based on your needs
data "aws_iam_policy_document" "inline_policy" {
  statement {
    sid = "AllowS3"
    actions = [
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}
