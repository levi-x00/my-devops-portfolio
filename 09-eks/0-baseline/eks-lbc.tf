####################################################################################
# Load Balancer Controller Installation
####################################################################################
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

  request_headers = {
    Accept = "application/json"
  }
}

module "lbc_irsa" {
  source = "../../modules/eks-irsa"

  role_name       = "${var.cluster_name}-lbc-controller"
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  custom_policy_json = data.http.lbc_iam_policy.response_body

  tags = {
    Name = "lbc-controller"
  }
}

resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    module.lbc_irsa
  ]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  # Recommended in prod, if not specified always uses latest version
  # version = "1.13.0"         

  # Wait for resources to become Ready
  wait    = true
  timeout = 600

  cleanup_on_fail = true

  set = [
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "clusterName"
      value = aws_eks_cluster.this.id
    },
    {
      name  = "vpcId"
      value = local.vpc_id
    },
    {
      name  = "region"
      value = var.aws_region
    }
  ]
}
