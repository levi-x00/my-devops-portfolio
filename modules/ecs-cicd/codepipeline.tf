resource "aws_codestarconnections_connection" "this" {
  name = "${var.service_name}-conn"

  provider_type = "GitHub"
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket_artf
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category = "Source"
      name     = "Source"

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.this.arn
        FullRepositoryId = var.repository_id
        BranchName       = var.branch_name
      }

      input_artifacts  = []
      output_artifacts = ["SourceArtifact"]

      namespace = "SourceVariables"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      region    = local.region
      run_order = 1
      version   = "1"
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        ProjectName = "${var.service_name}-codebuild"
      }
      input_artifacts  = ["SourceArtifact"]
      name             = "Build"
      namespace        = "BuildVariables"
      output_artifacts = ["BuildArtifact"]
      owner            = "AWS"
      provider         = "CodeBuild"
      region           = local.region
      role_arn         = aws_iam_role.codebuild_role.arn
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "Approval"
    action {
      category = "Approval"
      configuration = {
        CustomData      = "Dear reviewer please check"
        NotificationArn = local.sns_arn
      }

      input_artifacts  = []
      output_artifacts = []

      name      = "Checking"
      owner     = "AWS"
      provider  = "Manual"
      region    = local.region
      run_order = 1
      version   = jsonencode(1)
    }
  }

  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      configuration = {
        ClusterName       = var.cluster_name
        DeploymentTimeout = "10"
        FileName          = "imagedefinitions.json"
        ServiceName       = var.service_name
      }
      input_artifacts  = ["BuildArtifact"]
      output_artifacts = []

      name      = "Deploy"
      namespace = "DeployVariables"
      owner     = "AWS"
      provider  = "ECS"
      region    = local.region
      run_order = 1
      version   = "1"
    }
  }

  tags = {
    Name = "${var.service_name}-pipeline"
  }
}
