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

After the s3 and dynamodb setup for the backend in `provider.tf` replace the value of of this code snippet

```terraform
backend "s3" {
    bucket         = "s3-backend-tfstate-<random-string>"
    key            = "dev/network.tfstate"
    region         = "<region>"
    dynamodb_table = "dynamodb-lock-table-<random-string>"
}
```

After that run these commands to setup, for this case I'm using the default value in the `variables.tf` or you can create your own `.tfvars`

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
