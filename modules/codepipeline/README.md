# CodePipeline Module

Terraform module to provision an AWS CodePipeline with dynamic stages and artifact store configuration.

## Usage

```hcl
module "codepipeline" {
  source = "./modules/codepipeline"

  name = "my-pipeline"

  # option 1: let the module create the role and attach policies
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    aws_iam_policy.codepipeline_s3.arn,
  ]

  # option 2: bring your own role (overrides policy_arns)
  # iam_role_arn = aws_iam_role.codepipeline.arn

  artifact_store = [
    {
      location = aws_s3_bucket.artifacts.bucket
      type     = "S3"
    }
  ]

  stage = [
    {
      name             = "Source"
      action_name      = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "my-org"
        Repo       = "my-repo"
        Branch     = "main"
        OAuthToken = var.github_token
      }
    },
    {
      name             = "Build"
      action_name      = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.this.name
      }
    },
    {
      name            = "Deploy"
      action_name     = "ECS_Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ClusterName = "my-cluster"
        ServiceName = "my-service"
        FileName    = "imagedefinitions.json"
      }
    }
  ]

  tags = {
    Environment = "production"
    Team        = "devops"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | The identifier for the CodePipeline | `string` | - | yes |
| iam_role_arn | Existing IAM role ARN to use. If not provided, a role will be created by the module | `string` | `null` | no |
| policy_arns | List of IAM policy ARNs to attach to the module-managed role. Only used when `iam_role_arn` is not provided | `list(string)` | `[]` | no |
| artifact_store | Configuration of artifact store for CodePipeline | `list(object)` | `null` | no |
| stage | List of stages for the CodePipeline | `list(object)` | `[]` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

### `artifact_store` object

| Attribute | Description | Type | Required |
|-----------|-------------|------|----------|
| location | S3 bucket name for artifact storage | `string` | yes |
| type | Type of artifact store, use `"S3"` | `string` | yes |

### `stage` object

| Attribute | Description | Type | Required |
|-----------|-------------|------|----------|
| name | Stage name | `string` | yes |
| action_name | Action name within the stage | `string` | yes |
| category | Action category: `Source`, `Build`, `Deploy`, `Test`, `Invoke`, `Approval` | `string` | yes |
| owner | Action owner: `AWS`, `Custom`, `ThirdParty` | `string` | yes |
| provider | Action provider (e.g. `CodeBuild`, `ECS`, `GitHub`) | `string` | yes |
| version | Action version | `string` | yes |
| namespace | Variable namespace for the action | `string` | no |
| run_order | Execution order within the stage | `number` | no |
| role_arn | IAM role ARN for cross-account actions | `string` | no |
| region | AWS region for cross-region actions | `string` | no |
| input_artifacts | List of input artifact names | `list(string)` | no |
| output_artifacts | List of output artifact names | `list(string)` | no |
| configuration | Action-specific configuration map | `map(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the CodePipeline |
| id | The ID of the CodePipeline |
| role_arn | The IAM role ARN used by the CodePipeline |
