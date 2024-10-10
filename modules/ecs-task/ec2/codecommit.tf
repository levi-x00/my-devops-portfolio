resource "aws_codecommit_repository" "service_repo" {
  repository_name = "${var.service_name}-repo"
  tags = {
    Name = "${var.service_name}-repo"
  }
}

resource "null_resource" "upload_files" {
  depends_on = [
    aws_ecr_repository.this
  ]

  triggers = {
    files_hash = data.external.folder_hash.result.hash
  }

  provisioner "local-exec" {
    command = <<-EOT
    cd ${var.docker_file_path}

    git config --global credential.helper "!aws codecommit credential-helper $@"
    git config --global credential.UseHttpPath true

    git init
    git branch -m master

    git config user.name ${var.service_name}
    git config user.email ${var.service_name}

    git remote add origin ${aws_codecommit_repository.service_repo.clone_url_http}
    git pull
    git add .
    git commit -m "Initial commit/update"
    git push origin master

    rm -rf .git

    cd -
    EOT
  }
}
