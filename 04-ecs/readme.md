## ECS Deployment Architecture

![Alt text](../images/ecs-cluster.drawio.svg?raw=true "ECS Deployment Architecture")
Here I deploy the ECS cluster first, the services will come later

## Deploy the Terraform

- Configure the data remote tfstate and backend code from the output of `00-infra-backend` in `provider.tf` and `01-network-stack`in `data.tf`, change the bucket and dynamodb table name and the region based on your needs

```
backend "s3" {
    bucket         = "s3-backend-tfstate-xxxxxxx"
    key            = "dev/ecs-stack.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-lock-table-xxxxxxx"
}
```

```
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-xxxxxxx"
    key    = "${var.environment}/network.tfstate"
    region = "us-east-1"
  }
}
```

- Run these commands to deploy

```
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

- Go to ECS console to verify whether the ECS is deployed
