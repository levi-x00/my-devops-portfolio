data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "external" "folder_hash" {
  program = ["bash", "${path.module}/check-hash.sh", var.source_dir]
}

data "archive_file" "lambda_src" {
  depends_on = [null_resource.lambda_zip]
  excludes = [
    "__pycache__",
    "venv",
    "*.dist-info",
    "*.zip",
    "requirements.txt"
  ]

  source_dir  = var.source_dir
  output_path = "${var.source_dir}/${local.hash_source_dir}.zip"
  type        = "zip"
}
