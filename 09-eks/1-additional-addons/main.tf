#################################################################
# install aws load balancer controller
#################################################################
resource "helm_release" "load_balancer_controller" {
  depends_on = [aws_iam_role.load_balancer_controller]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.load_balancer_controller.arn
  }

  set {
    name  = "vpcId"
    value = local.cluster_vpc_id
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}

#################################################################
# install autoscaler
#################################################################
resource "helm_release" "cluster_autoscaler_release" {
  depends_on = [aws_iam_role.autoscaler]
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  namespace = "kube-system"

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.autoscaler.arn
  }
}
