# EKS CI/CD Stack

Terraform stack that provisions a full CI/CD pipeline for backend and frontend services deployed on EKS using AWS CodeCommit, CodeBuild, and CodePipeline.

## Architecture

```
CodeCommit → CodePipeline → CodeBuild → ECR → EKS
```

Each service (backend and frontend) has its own:
- CodeCommit repository — source code storage
- CodePipeline — orchestrates the pipeline (Source → Build)
- CodeBuild project — builds Docker image, pushes to ECR, deploys to EKS via `kubectl`

## Prerequisites

- `0-baseline` stack applied — EKS cluster and CodeBuild IAM role must exist
- `01-network-stack` applied — VPC, KMS key must exist
- ECR repositories for backend and frontend must exist
- `aws-codecommit-credential-helper` installed locally for the initial code push

## Usage

```bash
terraform init -backend-config=backend.config
terraform apply
```

## Remote State Dependencies

| Stack | Key |
|---|---|
| Network | `dev/network.tfstate` |
| EKS Baseline | `dev/eks-stack.tfstate` |

## Resources Created

| Resource | Description |
|---|---|
| `aws_codecommit_repository` | Backend and frontend source repositories |
| `aws_codepipeline` | Backend and frontend pipelines (via module) |
| `aws_codebuild_project` | Backend and frontend build projects |
| `aws_cloudwatch_log_group` | CodeBuild log groups |
| `aws_iam_role` | CodePipeline execution role |
| `aws_s3_bucket` | Artifacts bucket (via module) |
| `null_resource` | Initial code push to CodeCommit |

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| environment | Environment name | `string` | `dev` | no |
| application | Application name | `string` | `myapp` | no |
| aws_region | AWS region | `string` | `ap-southeast-1` | no |
| aws_profile | AWS CLI profile | `string` | `ics-sandbox` | no |
| cluster_name | EKS cluster name | `string` | - | yes |
| branch_name | Git branch to trigger the pipeline | `string` | `main` | no |
| backend_repository_name | CodeCommit repository name for backend | `string` | - | yes |
| frontend_repository_name | CodeCommit repository name for frontend | `string` | - | yes |
| build_timeout | CodeBuild build timeout in minutes | `number` | `30` | no |
| retention_in_days | CloudWatch log retention in days | `number` | `30` | no |
| git_user_email | Git user email for initial commit | `string` | - | yes |
| git_user_name | Git user name for initial commit | `string` | - | yes |
| tfstate_bucket | S3 bucket for Terraform remote state | `string` | - | yes |
| network_tfstate_key | S3 key for network stack tfstate | `string` | - | yes |
| eks_tfstate_key | S3 key for EKS baseline tfstate | `string` | - | yes |

## Outputs

| Name | Description |
|---|---|
| backend_pipeline_arn | ARN of the backend CodePipeline |
| frontend_pipeline_arn | ARN of the frontend CodePipeline |
| backend_codecommit_clone_url | HTTPS clone URL for the backend CodeCommit repository |
| frontend_codecommit_clone_url | HTTPS clone URL for the frontend CodeCommit repository |
| artifacts_bucket | S3 bucket used for pipeline artifacts |

## Notes

- The CodeBuild IAM role is managed in the `0-baseline` stack and referenced via remote state — any permission changes must be applied there first
- `PollForSourceChanges` is set to `false` on both pipelines — use EventBridge rules to trigger pipelines on CodeCommit push events
- The initial code push from `1-deploy-apps/backend` and `1-deploy-apps/frontend` is handled automatically via `null_resource` on `terraform apply`
- KMS encryption is applied to the artifacts S3 bucket and CodeBuild log groups using the key from the network stack
