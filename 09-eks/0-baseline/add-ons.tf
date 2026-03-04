data "aws_eks_addon_version" "main" {
  for_each = toset(var.cluster_addons)

  addon_name  = each.key
  most_recent = true

  kubernetes_version = aws_eks_cluster.this.version
}

resource "aws_eks_addon" "main" {
  for_each = toset(var.cluster_addons)

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.key
  addon_version = data.aws_eks_addon_version.main[each.key].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.this
  ]
}

####################################################################################
# amzn EBS CSI Driver
####################################################################################

module "ebs_csi_irsa" {
  source = "../../modules/eks-irsa"

  role_name       = "${var.cluster_name}-ebs-csi-controller"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  tags = {
    Name = "ebs-csi-controller"
  }
}

data "aws_eks_addon_version" "ebs_csi_latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  depends_on = [
    module.ebs_csi_irsa,
    aws_eks_addon.main,
    aws_eks_node_group.this
  ]

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_latest.version

  service_account_role_arn = module.ebs_csi_irsa.role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = {
    Name      = "${var.cluster_name}-aws-ebs-csi-addon"
    Component = "Amazon EBS CSI Driver"
  }
}
####################################################################################
# amzn cloudwatch observability
####################################################################################
module "amzn_cw_observability_irsa" {
  source = "../../modules/eks-irsa"

  role_name       = "${var.cluster_name}-amzn-cw-observability"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "amazon-cloudwatch-observability-sa"

  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]

  tags = {
    Name = "amazon-cloudwatch-observability"
  }
}

# resource "aws_eks_addon" "guardduty" {
#   cluster_name  = aws_eks_cluster.this.name
#   addon_name    = "aws-guardduty-agent"
#   addon_version = "v1.10.0-eksbuild.2"

#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

#   preserve = true
# }

####################################################################################
# Cluster Autoscaler
####################################################################################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  version = "9.43.0"

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = aws_eks_cluster.this.name
      }

      awsRegion = var.aws_region

      rbac = {
        create = true
      }

      serviceAccount = {
        create = true
        name   = "cluster-autoscaler-aws-cluster-autoscaler"
      }

      extraArgs = {
        balance-similar-node-groups   = "true"
        skip-nodes-with-system-pods   = "false"
        skip-nodes-with-local-storage = "false"
      }
    })
  ]
}
