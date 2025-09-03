data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  public_nacl_rules = {
    ingress = [
      {
        rule_no     = 100
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 22
        to_port     = 22
        description = "Allow SSH"
      },
      {
        rule_no     = 110
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 53
        to_port     = 53
        description = "Allow DNS resolution"
      },
      {
        rule_no     = 120
        protocol    = "udp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 53
        to_port     = 53
        description = "Allow DNS resolution"
      },
      {
        rule_no     = 130
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 80
        to_port     = 80
        description = "Allow HTTP"
      },
      {
        rule_no     = 140
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 443
        to_port     = 443
        description = "Allow HTTPS"
      },
      {
        rule_no     = 150
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 1024
        to_port     = 65535
        description = "Allow ephemeral ports"
      },
      {
        rule_no     = 160
        protocol    = "udp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 1024
        to_port     = 65535
        description = "Allow ephemeral ports"
      },
      {
        rule_no     = 170
        protocol    = "-1"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 0
        to_port     = 0
        description = "Allow icmp"
      }
    ]
  }

  private_nacl_rules = {
    ingress = [
      {
        rule_no     = 100
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "10.0.0.0/23"
        from_port   = 0
        to_port     = 65535
        description = "Allow inbound from public subnet"
      }
    ]

    egress = [
      {
        rule_no     = 100
        protocol    = "tcp"
        action      = "allow"
        cidr_block  = "0.0.0.0/0"
        from_port   = 0
        to_port     = 65535
        description = "Allow outbound to public subnet"
      }
    ]
  }
}
