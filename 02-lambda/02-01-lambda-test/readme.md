# Example How to Use the Lambda Module

### Configure AWS Profile

to configure a profile on your local

```
aws configure --profile <your-profile-name>
```

then update `variables.tf` for this part based on your profile name

```
variables "profile" {
  type    = string
  default = "<your-profile-name>"
}
```

### Apply The Terraform

```
terraform init
terraform plan
terraform apply -auto-approve
```
