resource "aws_iam_role_policy" "lbc_iam_policy" {
  name   = "lbc-iam-inline-policy"
  role   = aws_iam_role.lbc_iam_role.name
  policy = data.http.lbc_iam_policy.response_body
}

resource "aws_iam_role_policy" "externaldns_iam_policy" {
  name = "external-dns-inline-policy"
  role = aws_iam_role.external_dns_role.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lbc_iam_role" {
  name = "${local.cluster_id}-lbc-iam-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.iam_openid_conn_provider_arn}:aud" : "sts.amazonaws.com",
            "${local.iam_openid_conn_provider_arn}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      },
    ]
  })

  tags = {
    Name = "${local.cluster_id}-lbc-iam-role"
  }
}

resource "aws_iam_role" "external_dns_role" {
  name = "${local.cluster_id}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${data.terraform_remote_state.eks.outputs.aws_iam_openid_connect_provider_arn}"
        }
        Condition = {
          StringEquals = {
            "${local.iam_openid_conn_provider_arn}:aud" : "sts.amazonaws.com",
            "${local.iam_openid_conn_provider_arn}:sub" : "system:serviceaccount:default:external-dns"
          }
        }
      },
    ]
  })

  tags = {
    Name = "${local.cluster_id}-external-dns-role"
  }
}
