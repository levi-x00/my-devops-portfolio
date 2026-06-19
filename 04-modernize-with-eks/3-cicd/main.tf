module "backend_pipeline" {
  source = "../../modules/codepipeline"

  name         = "${var.cluster_name}-backend-pipeline"
  iam_role_arn = aws_iam_role.codepipeline.arn

  artifact_store = [
    {
      location = module.artifacts_bucket.bucket_name
      type     = "S3"
    }
  ]

  stage = [
    {
      name             = "Source"
      action_name      = "CodeCommit_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      namespace        = "SourceVariables"
      run_order        = 1
      output_artifacts = ["BackendSourceArtifact"]
      configuration = {
        RepositoryName       = var.backend_repository_name
        BranchName           = var.branch_name
        PollForSourceChanges = "false"
      }
    },
    {
      name             = "Build"
      action_name      = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      namespace        = "BuildVariables"
      run_order        = 1
      input_artifacts  = ["BackendSourceArtifact"]
      output_artifacts = ["BackendBuildArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  ]

  tags = {
    Name = "${var.cluster_name}-backend-pipeline"
  }
}

module "frontend_pipeline" {
  source = "../../modules/codepipeline"

  name         = "${var.cluster_name}-frontend-pipeline"
  iam_role_arn = aws_iam_role.codepipeline.arn

  artifact_store = [
    {
      location = module.artifacts_bucket.bucket_name
      type     = "S3"
    }
  ]

  stage = [
    {
      name             = "Source"
      action_name      = "CodeCommit_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      namespace        = "SourceVariables"
      run_order        = 1
      output_artifacts = ["FrontendSourceArtifact"]
      configuration = {
        RepositoryName       = var.frontend_repository_name
        BranchName           = var.branch_name
        PollForSourceChanges = "false"
      }
    },
    {
      name             = "Build"
      action_name      = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      namespace        = "BuildVariables"
      run_order        = 1
      input_artifacts  = ["FrontendSourceArtifact"]
      output_artifacts = ["FrontendBuildArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  ]

  tags = {
    Name = "${var.cluster_name}-frontend-pipeline"
  }
}
