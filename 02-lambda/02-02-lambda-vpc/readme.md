# Test the Lambda Module with VPC

Before proceed to this step make sure you already apply the terraform for the network infrastructure in `01-network-stack`, once it's done then update the s3 bucket name for remote tfstate in the `main.tf` file

```terraform
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-<unique-code>"
    key    = "${var.environment}/network.tfstate"
    region = "us-east-1"
  }
}
```

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

Go to AWS console then click <b>Test</b>
