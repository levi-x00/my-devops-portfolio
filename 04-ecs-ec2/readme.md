## ECS Deployment Architecture

![Alt text](../images/ecs-cluster.drawio.png?raw=true "ECS Deployment Architecture")<br>
Here I deploy the ECS cluster first, the services will come later

## ECS Configuration

- SSM session manager enabled, and the connection is encrypted with KMS, more about session manager exec you can go to this link.
  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-exec.html
- `ContainerInsights` enabled for monitoring

## Deploy ECS Cluster

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

## Deploy ECS Services

1. Go to `base-service` folder, in `src/templates/index.html` update the `location.href` based on your public domain, example

```html
<body>
  <h2>Welcome to the Base Service</h2>
  <button onclick="location.href='https://example.com/service-1'">
    Service 1
  </button>
  <button onclick="location.href='https://example.com/service-2'">
    Service 2
  </button>
</body>
```

2. Change the bucket name and the region each for cluster and network remote state in `main.tf`

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

```
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "s3-backend-tfstate-xxxxxxx"
    key    = "${var.environment}/ecs-stack.tfstate"
    region = "us-east-1"
  }
}
```

3. Change the bucket name, dynamodb table name and the region for the service backend in `main.tf`

```
backend "s3" {
  bucket         = "s3-backend-tfstate-xxxxxxx"
  key            = "dev/main-svc-stack.tfstate"
  region         = "us-east-1"
  dynamodb_table = "dynamodb-lock-table-xxxxxxx"
}
```

4. Once everything is set, as usual run the these commands to deploy

```bash
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

5. Repeat the step 1-4 for `service-1` and `service-2`

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
