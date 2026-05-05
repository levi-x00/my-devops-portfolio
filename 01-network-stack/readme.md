# Network Stack

## Network Architecture

![Network Architecture](../images/network-stack.drawio.svg "Network Architecture")

## Network Description

VPC `test-project-vpc` (`10.0.34.0/24`) in `ap-southeast-1` with two public subnets, two private subnets, and two DB subnets across AZs `ap-southeast-1a` and `ap-southeast-1b`. A single NAT Gateway (`enable_two_nats=false`) is deployed in the public subnet of AZ-a. An S3 Gateway VPC Endpoint is attached to both the public and private route tables.

| Subnet           | AZ              | CIDR           |
| ---------------- | --------------- | -------------- |
| Public subnet-a  | ap-southeast-1a | 10.0.34.0/28   |
| Public subnet-b  | ap-southeast-1b | 10.0.34.16/28  |
| Private subnet-a | ap-southeast-1a | 10.0.34.64/26  |
| Private subnet-b | ap-southeast-1b | 10.0.34.128/26 |
| DB subnet-a      | ap-southeast-1a | 10.0.34.32/27  |
| DB subnet-b      | ap-southeast-1b | 10.0.34.192/26 |

**Public Route Table** (`public-rt`)

| Destination | Target                                 | Subnets                          |
| ----------- | -------------------------------------- | -------------------------------- |
| 0.0.0.0/0   | igw (test-project-igw)                 | public subnet-a, public subnet-b |
| pl-xxx (S3) | s3-endpoint (test-project-s3-endpoint) | public subnet-a, public subnet-b |
| vpc-cidr    | local                                  |                                  |

**Private Route Table** (`private-rt`)

| Destination | Target                                   | Subnets                                                      |
| ----------- | ---------------------------------------- | ------------------------------------------------------------ |
| 0.0.0.0/0   | nat-gw (test-project-nat-gw1, AZ-a only) | private subnet-a, private subnet-b, db subnet-a, db subnet-b |
| pl-xxx (S3) | s3-endpoint (test-project-s3-endpoint)   | private subnet-a, private subnet-b, db subnet-a, db subnet-b |
| vpc-cidr    | local                                    |                                                              |

**Security Groups**

| Name       | Inbound                        | Outbound              |
| ---------- | ------------------------------ | --------------------- |
| default-sg | All traffic (self + 0.0.0.0/0) | All traffic           |
| vpce-sg    | HTTPS 443 from VPC CIDR        | HTTPS 443 to VPC CIDR |

**NACLs**

| Name         | Associated Subnets                                           |
| ------------ | ------------------------------------------------------------ |
| public-nacl  | public subnet-a, public subnet-b                             |
| private-nacl | private subnet-a, private subnet-b, db subnet-a, db subnet-b |

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
