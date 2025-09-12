# Network Stack

## Network Architecture

![Alt text](./network.jpg?raw=true "Network Architecture")

## Network Description

Here I have two public subnets, two private subnets and two DB subnets, one public route table, 2 private route tables for availability

<b>Public Route table</b>

| Destination | Target | Subnets         |
| ----------- | ------ | --------------- |
| 0.0.0.0/0   | igw-id | public subnet-a |
|             |        | public subnet-b |
| vpc-cidr    | local  |                 |

<b>Private Route table 1</b>
| Destination | Target | Subnets |
| --- | --- | --- |
|0.0.0.0/0|nat-gw-id2|private subnet-a|
|||db subnet-a|
|vpc-cidr|local||

<b>Private Route table 2</b>
| Destination | Target | Subnets |
| --- | --- | --- |
|0.0.0.0/0|nat-gw-id2|private subnet-b|
|||db subnet-b|
|vpc-cidr|local||

## VPC Setup

After s3 bucket created, now create a file name `backend.config`, this is the example of backend config

```
bucket = "s3-backend-tfstate-<random-string>"
key = "dev/network.tfstate"
region = "<region>"
encrypt = true
use_lockfile = true
```

After that run these commands to setup, for this case I'm using the default value in the `variables.tf` or you can create your own `.tfvars`

```sh
$ terraform init -backend-config=backend.config
$ terraform plan
$ terraform approve -auto-approve
```

if you have your own `.tfvars`

```sh
$ terraform init -backend-config=backend.config
$ terraform plan -var-file=terraform.tfvars
$ terraform approve -auto-approve -var-file=terraform.tfvars
```

for OpenTofu

```sh
$ tofu init -backend-config=backend.config
$ tofu plan
$ tofu apply -auto-approve
```

if you have your own `.tfvars`

```sh
$ tofu init -backend-config=backend.config
$ tofu plan -var-file=terraform.tfvars
$ tofu apply -auto-approve -var-file=terraform.tfvars
```
