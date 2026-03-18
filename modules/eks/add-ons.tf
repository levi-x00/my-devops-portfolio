data "aws_eks_addon_version" "main" {
  for_each = toset(var.cluster_addons)

  addon_name         = each.key
  most_recent        = true
  kubernetes_version = aws_eks_cluster.this.version
}

resource "aws_eks_addon" "main" {
  for_each = toset(var.cluster_addons)

  cluster_name  = aws_eks_cluster.this.name
  addon_name    = each.key
  addon_version = data.aws_eks_addon_version.main[each.key].version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.this]
}

####################################################################################
# EBS CSI Driver
####################################################################################
module "ebs_csi_irsa" {
  source = "../eks-irsa"

  role_name       = "${var.cluster_name}-ebs-csi-controller"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"

  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]

  tags = merge({ Name = "ebs-csi-controller" }, var.tags)
}

data "aws_eks_addon_version" "ebs_csi_latest" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.this.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.this.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi_latest.version

  service_account_role_arn = module.ebs_csi_irsa.role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.ebs_csi_irsa,
    aws_eks_addon.main,
    aws_eks_node_group.this
  ]

  tags = merge({ Name = "${var.cluster_name}-aws-ebs-csi-addon" }, var.tags)
}

####################################################################################
# CloudWatch Observability
####################################################################################
module "amzn_cw_observability_irsa" {
  source = "../eks-irsa"

  role_name       = "${var.cluster_name}-amzn-cw-observability"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "amazon-cloudwatch-observability-sa"

  policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

  tags = merge({ Name = "amazon-cloudwatch-observability" }, var.tags)
}

####################################################################################
# Cluster Autoscaler
####################################################################################
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.43.0"

  values = [
    yamlencode({
      autoDiscovery = { clusterName = aws_eks_cluster.this.name }
      awsRegion     = data.aws_region.current.region
      rbac          = { create = true }
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

####################################################################################
# Load Balancer Controller
####################################################################################
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = { Accept = "application/json" }
}

module "lbc_irsa" {
  source = "../eks-irsa"

  role_name       = "${var.cluster_name}-lbc-controller"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  custom_policy_json = data.http.lbc_iam_policy.response_body

  tags = merge({ Name = "lbc-controller" }, var.tags)
}

resource "helm_release" "loadbalancer_controller" {
  depends_on = [module.lbc_irsa]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  wait            = true
  timeout         = 600
  cleanup_on_fail = true

  set = [
    { name = "serviceAccount.create", value = "true" },
    { name = "serviceAccount.name", value = "aws-load-balancer-controller" },
    { name = "clusterName", value = aws_eks_cluster.this.id },
    { name = "vpcId", value = var.vpc_id },
    { name = "region", value = data.aws_region.current.region }
  ]
}
