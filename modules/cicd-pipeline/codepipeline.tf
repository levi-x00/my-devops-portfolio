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
      configuration = {
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
        PollForSourceChanges = "false"
        RepositoryName       = var.repository_name
      }
      input_artifacts  = []
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "CodeCommit"
      region           = local.region
      role_arn         = null
      run_order        = 1
      version          = "1"
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
      name             = "Checking"
      output_artifacts = []
      owner            = "AWS"
      provider         = "Manual"
      region           = local.region
      run_order        = 1
      version          = jsonencode(1)
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
      name             = "Deploy"
      namespace        = "DeployVariables"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      region           = local.region
      role_arn         = null
      run_order        = 1
      version          = "1"
    }
  }

  tags = {
    Name = "${var.service_name}-pipeline"
  }
}
