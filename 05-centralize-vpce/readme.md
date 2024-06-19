## Centralize VPC Endpoint Architecture

![Alt text](../images/centralized-vpce.drawio.svg?raw=true "ECS Deployment Architecture")<br>

1. Spoke VPC 1 & 2 connected with the central VPC with some endpoints setup
2. Spoke VPC 1, spoke VPC 2, and the central VPC need to be associated with Route 53 private hosted zone
3. The spoke VPC 1 & 2 will resolve the VPC endpoints in Route 53 private hosted zone
4. Some consideration for endpoint policy is limited with 20480 characters, let's say if you have a lot VPCs need to use this central endpoints
5. Make sure you have enough a pool of IP addresses, when there are spikes of network traffic, the VPC endpoints nodes will scale out (automatically)

References:

- https://aws.amazon.com/blogs/networking-and-content-delivery/centralize-access-using-vpc-interface-endpoints/
- https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/centralized-access-to-vpc-private-endpoints.html

## Purpose

- Cost saving for having small number of VPC endpoints
- Security compliance by using private link communication with AWS services

## Deploy

```
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

## Testing
