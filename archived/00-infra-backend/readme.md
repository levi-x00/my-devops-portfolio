# Infra Backend

This creates the S3 bucket used as the Terraform remote backend to store and share state files across engineers. The bucket name is randomized with a 7-character suffix to ensure uniqueness. An S3 bucket policy is also applied to enforce SSL-only access.

## Resources Created

- `aws_s3_bucket` — stores the Terraform state files (`s3-backend-tfstate-<random>`)
- `aws_s3_bucket_server_side_encryption_configuration` — encrypts state files using KMS
- `aws_s3_bucket_policy` — denies all non-SSL requests to the bucket
- `aws_kms_key` + `aws_kms_alias` + `aws_kms_key_policy` — KMS key used for S3 encryption
- `random_string` — generates a 7-character lowercase alphanumeric suffix for the bucket name

## Prerequisites

- Terraform `>=1.14.0`
- AWS provider `6.42.0`
- AWS profile configured (e.g.: `my-sandbox`)

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region to deploy resources |
| `aws_profile` | — | AWS CLI profile to use |
| `environment` | `dev` | Environment tag |
| `application` | `infra-prerequisites` | Application tag |

## terraform.tfvars
```
aws_profile = "my-sandbox"
aws_region  = "ap-southeast-1"
application = "devops-apps"
```

## Usage

Inside the `00-infra-backend` folder run:

```sh
$ terraform init
$ terraform plan -var-file=terraform.tfvars
$ terraform apply -var-file=terraform.tfvars -auto-approve
```

Copy the `s3_bucket_name` from the output and use it as the backend configuration for other stacks.
