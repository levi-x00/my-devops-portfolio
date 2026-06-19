## VPC Peering with Transit Gateway Architecture

![Alt text](../images/connect-vpc-tgw.drawio.svg?raw=true "VPC Peering with Transit Gateway Architecture")

### Architecture Overview
1. VPC 1 & VPC 2 connected via Transit Gateway
2. EC2 instances in private subnets of each VPC
3. Transit Gateway attachments for both VPCs
4. VPC endpoints for SSM access
5. Cross-VPC communication through Transit Gateway

### Setup Steps

#### Prerequisites
- AWS CLI configured
- Terraform installed

#### 1. Setup Terraform State Backend
First, run the infrastructure backend setup to create the S3 bucket for Terraform state:
```bash
cd ../00-infra-backend
terraform init
terraform plan
terraform apply
cd ../06-vpc-peering-tgw
```

#### 2. Configure Backend
Update `backend.config` with your S3 bucket details:
```
bucket = "your-terraform-state-bucket"
key    = "vpc-peering-tgw/terraform.tfstate"
region = "us-east-1"
```

#### 2. Initialize Terraform
```bash
terraform init -backend-config=backend.config
```

#### 3. Plan and Apply
```bash
terraform plan
terraform apply
```

#### 4. Verify Connectivity
Connect to instances via Session Manager and test connectivity between VPCs:
   ```bash
   # From instance-01, ping instance-02
   ping <instance-02-private-ip>
   ```

#### 5. Cleanup
```bash
terraform destroy
```

### Resources Created
- 2 VPCs with public/private subnets
- Transit Gateway with VPC attachments
- EC2 instances in private subnets
- VPC endpoints for SSM
- Security groups and IAM roles
