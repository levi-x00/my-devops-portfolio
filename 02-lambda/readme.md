# My AWS Lambda Template

### Disclaimer

Please not that this terrafor AWS lambda only available for Python runtime for now

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
