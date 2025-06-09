# EKS

## Infrastructure Architecture

<!-- put here -->
<!-- ![Alt text](./network.jpg?raw=true "Network Architecture") -->

## How Setup

After the VPC already setup from `01-vpc-tf-module`, modify `data.tf` and `provider.tf`. Replace the unique code

```terraform
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-<unique-code>"
    key    = "dev/network.tfstate"
    region = var.region
  }
}
```

Replace the unique code and the region

```terraform
terraform {
  backend "s3" {
    bucket       = "s3-backend-tfstate-<unique-code>"
    key          = "dev/eks-stack.tfstate"
    region       = <region>
    encrypt      = true
    use_lockfile = true
  }

  // code snippets
}
```

Once done, run the following commands

```sh
$ terraform init
$ terraform plan
$ terraform approve -auto-approve
```

for OpenTofu
for OpenTofu

```sh
$ tofu init
$ tofu plan
$ tofu apply -auto-approve
```
