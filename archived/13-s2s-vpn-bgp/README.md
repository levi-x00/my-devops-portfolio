# Site-to-Site VPN with BGP

Simulates an AWS Site-to-Site VPN with BGP dynamic routing. An EC2 instance running strongSwan acts as the on-premises customer gateway router, connected to AWS via Transit Gateway.

## Architecture

- **Cloud VPC** — simulates the AWS side, attached to Transit Gateway
- **On-prem VPC** — simulates a corporate data center; EC2 router instances run strongSwan for IPsec + BGP
- **Transit Gateway** — ASN `64512`, ECMP support enabled, separate route tables for cloud and on-prem sides
- **VPN Connection** — two tunnels per AWS best practice for redundancy
- **BGP** — dynamic route propagation between on-prem router and Transit Gateway

## Resources Created

- Transit Gateway with separate route tables per side
- Site-to-Site VPN connection with two tunnels
- EC2 router instances (Ubuntu + strongSwan) as customer gateways
- EC2 test instances in each VPC for connectivity verification
- IAM roles for SSM access (no bastion required)
- Route tables with BGP-propagated routes

## Prerequisites

- AWS CLI configured
- Terraform `>=1.x`
- Ubuntu AMI ID supporting strongSwan (set `router_ami_id` variable)

## Usage

Create a `terraform.tfvars`:

```hcl
aws_profile          = "your-profile"
aws_region           = "ap-southeast-1"
cloud_vpc_cidr_block = "10.0.0.0/16"
onprem_vpc_cidr_block = "192.168.0.0/16"
router_ami_id        = "ami-xxxxxxxxxxxxxxxxx"  # Ubuntu with strongSwan
ami_id               = "ami-xxxxxxxxxxxxxxxxx"  # Amazon Linux 2023
instance_type        = "t3.micro"
router_instance_type = "t3.small"
```

Then run:

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Testing

Connect to the test EC2 instances via Session Manager and ping across the VPN:

```bash
# From cloud-side EC2, ping on-prem EC2
ping <onprem-instance-private-ip>

# From on-prem EC2, ping cloud-side EC2
ping <cloud-instance-private-ip>
```

Verify BGP routes are being exchanged by checking the Transit Gateway route tables in the AWS console.
