## ECS Deployment Architecture

![Alt text](../images/ecs-cluster.drawio.svg?raw=true "ECS Deployment Architecture")<br>
Here I deploy the ECS cluster first, the services will come later

## ECS Configuration

- SSM session manager enabled, and the connection is encrypted with KMS, more about session manager exec you can go to this link.
  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
- `ContainerInsights` enabled for monitoring

## Deploy ECS Cluster

- Apply the infra backend for the network infrastructure in `00-infra-backend`, once it's done copy the s3 backend & dynamodb table

- In `01-network-stack`, update `provider.tf` for the s3 backend and dynamodb table, then apply the network stack

```
backend "s3" {
  bucket         = "s3-backend-tfstate-xxxxxxx"
  key            = "dev/network.tfstate"
  region         = "us-east-1"
  dynamodb_table = "dynamodb-lock-table-xxxxxxx"
}
```

- Now in `04-ecs`, configure the data remote tfstate and backend code from the output of `00-infra-backend` in `provider.tf` and `01-network-stack`in `data.tf`, change the bucket and dynamodb table name and the region based on your needs

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

## Deploy ECS Services

1. In `service-1` and `service-2`, configure the backend and the remote tfstate in `data.tf` and `main.tf` based on your bucket name and region

```
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-xxxxxxx"
    key    = "dev/network.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-xxxxxxx"
    key    = "dev/ecs-stack.tfstate"
    region = "us-east-1"
  }
}
```

2. Once done make sure you have docker service running on your current environment

```bash
$ docker --version
```

3. Apply the service 1 and 2

```bash
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

4. Once the service 1 and 2 setup copy the cloud map domain from Route53 into `base-service` dockerfile

## Testing

- Access the base service

```bash
$ curl https://example.com
```

- Access the service 1

```bash
$ curl https://example.com/service-1
```

- Access the service 2

```bash
$ curl https://example.com/service-2
```

- Try to session manager for each service with this command (e.g service-1)

```bash
aws ecs execute-command \
    --cluster devops-blueprint \
    --task d789e94343414c25b9f6bd59eEXAMPLE \
    --container service-1 \
    --interactive \
    --command "/bin/sh"
```
