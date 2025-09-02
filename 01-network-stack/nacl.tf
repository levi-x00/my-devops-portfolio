resource "aws_default_network_acl" "def-nacl" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  subnet_ids = [
    aws_subnet.public-1a.id,
    aws_subnet.public-1b.id,
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id,
    aws_subnet.db-1a.id,
    aws_subnet.db-1b.id
  ]

  dynamic "ingress" {
    for_each = [
      { rule_no = 90, protocol = "6", action = "allow", from = 22, to = 22 },         # SSH
      { rule_no = 95, protocol = "6", action = "allow", from = 53, to = 53 },         # DNS TCP
      { rule_no = 96, protocol = "17", action = "allow", from = 53, to = 53 },        # DNS UDP
      { rule_no = 100, protocol = "6", action = "allow", from = 80, to = 80 },        # HTTP
      { rule_no = 110, protocol = "6", action = "allow", from = 443, to = 443 },      # HTTPS
      { rule_no = 120, protocol = "6", action = "allow", from = 8200, to = 8200 },    # Vault
      { rule_no = 130, protocol = "6", action = "allow", from = 9200, to = 9200 },    # SonarQube
      { rule_no = 140, protocol = "17", action = "allow", from = 13231, to = 13231 }, # WireGuard
      { rule_no = 150, protocol = "6", action = "allow", from = 1024, to = 65535 },   # Ephemeral TCP
      { rule_no = 160, protocol = "17", action = "allow", from = 1024, to = 65535 },  # Ephemeral UDP
      { rule_no = 170, protocol = "-1", action = "allow", from = 0, to = 0 },         # ICMP
    ]
    content {
      rule_no    = ingress.value.rule_no
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = "0.0.0.0/0"
      from_port  = ingress.value.from
      to_port    = ingress.value.to
    }
  }

  dynamic "egress" {
    for_each = [
      { rule_no = 90, protocol = "6", action = "allow", from = 22, to = 22 },         # SSH
      { rule_no = 95, protocol = "6", action = "allow", from = 53, to = 53 },         # DNS TCP
      { rule_no = 96, protocol = "17", action = "allow", from = 53, to = 53 },        # DNS UDP
      { rule_no = 100, protocol = "6", action = "allow", from = 80, to = 80 },        # HTTP
      { rule_no = 110, protocol = "6", action = "allow", from = 443, to = 443 },      # HTTPS
      { rule_no = 120, protocol = "6", action = "allow", from = 8200, to = 8200 },    # Vault
      { rule_no = 130, protocol = "6", action = "allow", from = 9200, to = 9200 },    # SonarQube
      { rule_no = 140, protocol = "17", action = "allow", from = 13231, to = 13231 }, # WireGuard
      { rule_no = 150, protocol = "6", action = "allow", from = 1024, to = 65535 },   # Ephemeral TCP
      { rule_no = 160, protocol = "17", action = "allow", from = 1024, to = 65535 },  # Ephemeral UDP
      { rule_no = 170, protocol = "-1", action = "allow", from = 0, to = 0 },         # ICMP
    ]
    content {
      rule_no    = egress.value.rule_no
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = "0.0.0.0/0"
      from_port  = egress.value.from
      to_port    = egress.value.to
    }
  }

  tags = {
    Name = "${var.project_name}-default-nacl"
  }
}
