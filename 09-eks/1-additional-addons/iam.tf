#################################################################
# aws load balancer controller IAM
#################################################################
data "aws_iam_policy_document" "lbc_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.openid_connect_provider_cluster_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(local.openid_connect_provider_cluster_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "load_balancer_controller" {
  name        = "${local.cluster_name}-load-balancer-controller"
  description = "Allow load-balancer-controller to manage ALBs and NLBs."

  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role_policy.json

  force_detach_policies = true
  tags = {
    Name                      = "${local.cluster_name}-load-balancer-controller"
    "ServiceAccountName"      = "aws-load-balancer-controller"
    "ServiceAccountNamespace" = "kube-system"
  }
}

resource "aws_iam_role_policy" "load_balancer_controller" {
  name   = "lbc-inline-policy"
  role   = aws_iam_role.load_balancer_controller.name
  policy = data.http.lbc_iam_policy.response_body
}

#################################################################
# aws autoscaler IAM
#################################################################
data "aws_iam_policy_document" "autoscaler_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [local.openid_connect_provider_cluster_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(local.openid_connect_provider_cluster_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "autoscaler" {
  name = "${local.cluster_name}-autoscaler"

  assume_role_policy = data.aws_iam_policy_document.autoscaler_assume_role_policy.json

  force_detach_policies = true
  tags = {
    Name                      = "${local.cluster_name}-cluster-autoscaler"
    "ServiceAccountName"      = "cluster-autoscaler"
    "ServiceAccountNamespace" = "kube-system"
  }
}

data "aws_iam_policy_document" "autoscaler_policy" {
  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeInstanceTypes"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "autoscaler" {
  name   = "autoscaler-inline-policy"
  role   = aws_iam_role.autoscaler.name
  policy = data.aws_iam_policy_document.autoscaler_policy.json
}
