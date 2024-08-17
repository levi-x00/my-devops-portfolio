resource "aws_ecr_repository" "repo" {
  name = local.ecr_repository_name
  tags = {
    Name = local.ecr_repository_name
  }
}

resource "null_resource" "ecr_image" {
  triggers = {
    source_dir_hash = local.source_dir_hash
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
      cd ${var.source_dir}
      docker build -t ${aws_ecr_repository.repo.repository_url}:${local.image_tag} .
      docker push ${aws_ecr_repository.repo.repository_url}:${local.image_tag}
    EOF
  }
}

data "aws_ecr_image" "lambda_image" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = local.ecr_repository_name
  image_tag       = local.image_tag
}

resource "aws_lambda_function" "this" {
  depends_on = [
    null_resource.ecr_image
  ]

  function_name = local.function_name
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.timeout
  memory_size   = var.memory_size

  image_uri    = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type = "Image"

  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = local.security_group_ids
  }

  tags = {
    Name = local.function_name
  }
}
