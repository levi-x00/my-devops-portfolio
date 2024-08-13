# Infra Backend

This is a requirement to create the s3 bucket and dynamodb table for terraform backend. The purpose of this backend is the s3 bucket used to store the terraform state file to ensure the state is persisted and can be shared with engineers on the other hand the dynamodb table used for state locking that prevent race conditions and potential state corruption.

Inside the `00-infra-backend` folder you can run this command

```sh
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

for OpenTofu

```sh
$ tofu init
$ tofu plan
$ tofu apply -auto-approve
```

copy the `s3_bucket_name` and `dynamodb_table_name` from the output
