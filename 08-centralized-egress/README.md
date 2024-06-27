## Centralized Egress Architecture

![Alt text](../images/centralized-egress.drawio.svg?raw=true "Centralized Egress Internet Architecture")<br>

1. Traffic from the lambda function in the private subnet attempts to reach the internet, the subnet's route table routes to transit gateway (0.0.0.0/0)
2. Traffic enters transit gateway on the transit gateway attachment and it's routed to the egress VPC via the route table in transit gateway
3. Traffic enters the egress VPC on the transit gateway attachment subnet
4. The subnet's route table routes the traffic to the NAT gateway, then the source IP is changed to NAT gateway IP
5. After exiting the NAT gateway, the traffic looks up the public subnet route table then get routed to internet gateway

References:

- https://aws.amazon.com/blogs/networking-and-content-delivery/creating-a-single-internet-exit-point-from-multiple-vpcs-using-aws-transit-gateway/
- https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/centralized-egress-to-internet.html

## Deploy

```
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
```

## Testing

Run each lambda function to test whether the lambda can reach the internet the output should be like this

```
START RequestId: 7f1e4d68-65f1-418b-accb-29badb598145 Version: $LATEST
https://api.github.com/
200
END RequestId: 7f1e4d68-65f1-418b-accb-29badb598145
REPORT RequestId: 7f1e4d68-65f1-418b-accb-29badb598145	Duration: 33.74 ms	Billed Duration: 34 ms	Memory Size: 256 MB	Max Memory Used: 51 MB	Init Duration: 342.83 ms
```
