# Infra Backend

This creates the S3 bucket used as the Terraform remote backend to store and share state files across engineers. The bucket name is randomized with a 7-character suffix to ensure uniqueness. An S3 bucket policy is also applied to enforce SSL-only access.

## Resources Created

- `aws_s3_bucket` — stores the Terraform state files (`s3-backend-tfstate-<random>`)
- `aws_s3_bucket_policy` — denies all non-SSL requests to the bucket
- `random_string` — generates a 7-character lowercase alphanumeric suffix for the bucket name

## Prerequisites

- Terraform `>= 1.10.0`
- AWS provider `6.42.0`
- AWS profile configured (default: `ics-sandbox`)

## Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region to deploy resources |
| `aws_profile` | — | AWS CLI profile to use |
| `environment` | `dev` | Environment tag |
| `application` | `infra-prerequisites` | Application tag |

## Usage

Inside the `00-infra-backend` folder run:

```sh
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

Copy the `s3_bucket_name` from the output and use it as the backend configuration for other stacks.
