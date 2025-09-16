## ECS Deployment Architecture

This is the ECS cluster architecture
![Alt text](../images/ecs-cloudmap.drawio.svg?raw=true "ECS Deployment Architecture")<br>

and this is the flow of the CI/CD pipeline using AWS native tools with CodePipeline, CodeBuild, and CodeDeploy

![Alt text](../images/cicd-ecs-blue-green.drawio.svg?raw=true "ECS Deployment Architecture")<br>
In short:

1. The developer commit changes
2. Then webhook trigger the CodePipeline to checkout from repository
3. In CodeBuild the changes is being built the pushed to ECR, tested with pytest, and scanned using trivy
4. The build process will failed if the automated testing and the security test failed if not will send notification for approval
5. Once the changes approved then it will be deployed in ECS with blue/green deployment

## ECS Configuration

- SSM session manager enabled, and the connection is encrypted with KMS, more about session manager exec you can go to this link.
  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
- `ContainerInsights` enabled for monitoring

## Deploy ECS Cluster

- Apply the infra backend for the network infrastructure in `00-infra-backend`, once it's done copy the s3 backend & dynamodb table

- In `01-network-stack`, deploy the VPC and the subnets

- Now in `04-ecs`, create `backend.config` file and `terraform.tfvars`, for example:

```
# backend.config
bucket = "s3-backend-tfstate-xxxxxx"
key    = "dev/ecs-stack.tfstate"
region = "ap-southeast-1"
encrypt = true
profile = "sandbox"
use_lockfile = true
```

first make sure that you already have DNS setup in route53, if not, the existing codes here can be modified based on your needs

```
# terraform.tfvars
cluster_name = "devops-blueprint"
aws_region = "ap-southeast-1"
aws_profile = "sandbox"
environment = "dev"
application = "devops-blueprint-app"
service_domain = "example.com"
retention_days = 3

tfstate_bucket = "s3-backend-tfstate-xxxxxxx"
tfstate_key = "dev/network.tfstate"

```

- Run these commands to deploy

```
$ terraform init -backend-config=backend.config
$ terraform plan -var-file=terraform.tfvars
$ terraform apply -auto-approve -var-file=terraform.tfvars
```

- Go to ECS console to verify whether the ECS is deployed

## Deploy ECS Services and CI/CD Pipeline

1. Go to directory `services`, same way to deploy the ECS cluster, first create the `backend.config`

```
bucket = "s3-backend-tfstate-nig4odz"
key = "dev/services-stack.tfstate"
region = "ap-southeast-1"
profile = "sandbox"
encrypt = true
use_lockfile = true
```

2. Create `terraform.tfvars`, replace the following variables based on your needs

```
tfstate_bucket      = "s3-backend-tfstate-xxxxxx"
tfstate_ecs_key     = "dev/ecs-stack.tfstate"
tfstate_network_key = "dev/network.tfstate"

aws_profile = "sandbox"
aws_region  = "ap-southeast-1"
```

3. To deploy, run the following commands

```bash
$ terraform init -backend.config
$ terraform plan -var-file=terraform.tfvars
$ terraform apply -auto-approve -var-file=terraform.tfvars
```

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
