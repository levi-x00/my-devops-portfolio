resource "aws_cloudwatch_log_group" "backend" {
  name              = "/aws/codebuild/${var.cluster_name}-backend"
  retention_in_days = var.retention_in_days
  kms_key_id        = local.kms_key_arn
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/aws/codebuild/${var.cluster_name}-frontend"
  retention_in_days = var.retention_in_days
  kms_key_id        = local.kms_key_arn
}

resource "aws_codebuild_project" "backend" {
  name           = "${var.cluster_name}-backend"
  description    = "Build and deploy backend to EKS"
  service_role   = local.codebuild_role_arn
  build_timeout  = var.build_timeout
  encryption_key = local.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = local.region
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = local.cluster_name
    }

    environment_variable {
      name  = "ECR_REPO"
      value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/backend"
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = "backend"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.backend.name
      status     = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        pre_build:
          commands:
            - echo Logging in to Amazon ECR...
            - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
            - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c1-7)
            - IMAGE_URI=$ECR_REPO:$IMAGE_TAG
            - aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
        build:
          commands:
            - echo Building Docker image...
            - docker build -t $IMAGE_URI .
            - docker push $IMAGE_URI
        post_build:
          commands:
            - echo Deploying to EKS...
            - kubectl set image deployment/backend backend=$IMAGE_URI -n $K8S_NAMESPACE
            - kubectl rollout status deployment/backend -n $K8S_NAMESPACE
    EOT
  }
}

resource "aws_codebuild_project" "frontend" {
  name           = "${var.cluster_name}-frontend"
  description    = "Build and deploy frontend to EKS"
  service_role   = local.codebuild_role_arn
  build_timeout  = var.build_timeout
  encryption_key = local.kms_key_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = local.region
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = local.cluster_name
    }

    environment_variable {
      name  = "ECR_REPO"
      value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/frontend"
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = "frontend"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.frontend.name
      status     = "ENABLED"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        pre_build:
          commands:
            - echo Logging in to Amazon ECR...
            - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
            - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c1-7)
            - IMAGE_URI=$ECR_REPO:$IMAGE_TAG
            - aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER_NAME
        build:
          commands:
            - echo Building Docker image...
            - docker build -t $IMAGE_URI .
            - docker push $IMAGE_URI
        post_build:
          commands:
            - echo Deploying to EKS...
            - kubectl set image deployment/frontend frontend=$IMAGE_URI -n $K8S_NAMESPACE
            - kubectl rollout status deployment/frontend -n $K8S_NAMESPACE
    EOT
  }
}
