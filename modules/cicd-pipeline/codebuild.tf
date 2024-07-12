resource "aws_cloudwatch_log_group" "cb_logs" {
  name = "/aws/codebuild/${var.service_name}-logs"

  retention_in_days = var.retention_days
  kms_key_id        = local.kms_key_arn

  tags = {
    Name = "${var.service_name}-logs"
  }
}

resource "aws_codebuild_project" "codebuild" {
  badge_enabled  = false
  build_timeout  = var.build_timeout
  description    = "codebuild for CI/CD pipeline"
  encryption_key = local.kms_key_arn
  name           = "${var.service_name}-codebuild"
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild_role.arn

  artifacts {
    name                   = "${var.service_name}-codebuild"
    namespace_type         = null
    override_artifact_name = false
    packaging              = "NONE"
    path                   = null
    type                   = "CODEPIPELINE"
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
      value = data.aws_caller_identity.current.account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.service_name}-logs"
      status     = "ENABLED"
    }
  }

  # vpc_config {
  #   vpc_id             = var.vpc_id == null ? null : local.vpc_id
  #   subnets            = var.vpc_id == null ? null : local.private_subnets
  #   security_group_ids = var.vpc_id == null ? null : [local.codebuild_sg_id]
  # }

  source {
    buildspec           = "buildspec.yml"
    git_clone_depth     = 0
    insecure_ssl        = false
    location            = null
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}
