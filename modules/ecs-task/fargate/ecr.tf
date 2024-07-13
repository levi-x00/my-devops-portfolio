# provider "local" {}

resource "aws_ecr_repository" "this" {
  name = "${var.service_name}-ecr"

  force_delete = true
  tags = {
    Name = "${var.service_name}-ecr"
  }
}

data "external" "folder_hash" {
  program = ["bash", "${path.module}/hash-folder.sh", var.docker_file_path]
}

resource "null_resource" "push_image" {
  depends_on = [
    aws_ecr_repository.this
  ]

  triggers = {
    files_hash = data.external.folder_hash.result.hash
  }

  provisioner "local-exec" {
    command = <<EOT
    cd ${var.docker_file_path}
    aws ecr get-login-password --region ${local.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region}.amazonaws.com
    docker build -t ${var.service_name} .
    docker tag ${var.service_name}:latest ${aws_ecr_repository.this.repository_url}:latest
    docker push ${aws_ecr_repository.this.repository_url}:latest
    cd -
    EOT
  }
}
