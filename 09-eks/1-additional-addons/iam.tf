#################################################################
# RBAC
#################################################################
data "aws_iam_policy_document" "rbac_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:user/cloud_user"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_rbac" {
  name = "${local.cluster_name}-rbac"

  assume_role_policy = data.aws_iam_policy_document.rbac_assume_role.json

  force_detach_policies = true
  tags = {
    Name = "${local.cluster_name}-rbac"
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.eks_rbac.name
}

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
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "autoscaler" {
  name   = "autoscaler-inline-policy"
  role   = aws_iam_role.autoscaler.name
  policy = data.aws_iam_policy_document.autoscaler_policy.json
}
