resource "aws_codecommit_repository" "backend" {
  repository_name = var.backend_repository_name
  description     = "CodeCommit repository for backend service"

  tags = {
    Name = var.backend_repository_name
  }
}

resource "aws_codecommit_repository" "frontend" {
  repository_name = var.frontend_repository_name
  description     = "CodeCommit repository for frontend service"

  tags = {
    Name = var.frontend_repository_name
  }
}

resource "null_resource" "push_backend" {
  depends_on = [aws_codecommit_repository.backend]

  triggers = {
    repo_url = aws_codecommit_repository.backend.clone_url_http
  }

  provisioner "local-exec" {
    command = <<-EOT
      export AWS_PROFILE=${var.aws_profile}
      cd ${abspath(path.module)}/../1-deploy-apps/backend
      git init -b main
      git config credential.helper '!aws codecommit credential-helper $@'
      git config credential.UseHttpPath true
      git config user.email "terraform@example.com"
      git config user.name "terraform"
      git remote remove origin 2>/dev/null || true
      git remote add origin ${aws_codecommit_repository.backend.clone_url_http}
      git add .
      git commit -m "Initial commit" 2>/dev/null || true
      git push origin main
      unset AWS_PROFILE
    EOT
  }
}

resource "null_resource" "push_frontend" {
  depends_on = [aws_codecommit_repository.frontend]

  triggers = {
    repo_url = aws_codecommit_repository.frontend.clone_url_http
  }

  provisioner "local-exec" {
    command = <<-EOT
      export AWS_PROFILE=${var.aws_profile}
      cd ${abspath(path.module)}/../1-deploy-apps/frontend
      git init -b main
      git config credential.helper '!aws codecommit credential-helper $@'
      git config credential.UseHttpPath true
      git config user.email "terraform@example.com"
      git config user.name "terraform"
      git remote remove origin 2>/dev/null || true
      git remote add origin ${aws_codecommit_repository.frontend.clone_url_http}
      git add .
      git commit -m "Initial commit" 2>/dev/null || true
      git push origin main
      unset AWS_PROFILE
    EOT
  }
}
