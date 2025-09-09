resource "aws_cloudwatch_log_group" "cb_logs" {
  name = "/aws/codebuild/${var.service_name}-logs"

  retention_in_days = var.retention_days
  kms_key_id        = local.kms_key_arn

  tags = {
    Name = "${var.service_name}-logs"
  }
}

resource "aws_security_group" "codebuild" {
  vpc_id = local.vpc_id
  name   = "${var.service_name}-codebuild-sg"

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.service_name}-codebuild-sg"
  }
}

resource "aws_codebuild_project" "codebuild" {
  badge_enabled  = false
  build_timeout  = var.build_timeout
  description    = "${var.service_name} codebuild CI/CD pipeline"
  encryption_key = local.kms_key_arn
  name           = "${var.service_name}-codebuild"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    name      = "${var.service_name}-codebuild"
    packaging = "NONE"
    path      = null
    type      = "CODEPIPELINE"

    namespace_type         = null
    override_artifact_name = false
  }

  cache {
    location = null
    modes    = []
    type     = "NO_CACHE"
  }

  environment {
    certificate     = null
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    privileged_mode = true
    type            = "LINUX_CONTAINER"

    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "CODEBUILD_CONFIG_AUTO_DISCOVER"
      type  = "PLAINTEXT"
      value = "true"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = local.account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.service_name}-logs"
      status     = "ENABLED"
    }
  }

  vpc_config {
    vpc_id             = local.vpc_id
    subnets            = local.private_subnets
    security_group_ids = [aws_security_group.codebuild.id]
  }

  source {
    buildspec           = "buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    location            = null
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
