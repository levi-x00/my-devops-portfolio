resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.retention_in_days
}

resource "null_resource" "lambda_zip" {
  triggers = {
    source_dir_hash = local.hash_source_dir
  }

  provisioner "local-exec" {
    command = <<EOT
      pip install -r ${var.source_dir}/requirements.txt -t ${var.source_dir}
      # rm -rf ${var.source_dir}/*.dist-info
    EOT
  }
}

resource "aws_lambda_function" "this" {
  depends_on = [
    null_resource.lambda_zip,
    aws_cloudwatch_log_group.lambda_log
  ]

  function_name = local.function_name

  handler     = var.handler
  runtime     = var.runtime
  timeout     = var.timeout
  role        = aws_iam_role.lambda_role.arn
  memory_size = var.memory_size

  filename         = data.archive_file.lambda_src.output_path
  source_code_hash = data.archive_file.lambda_src.output_base64sha256

  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }
}
