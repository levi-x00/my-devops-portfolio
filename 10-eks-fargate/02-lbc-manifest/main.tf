# Install AWS Load Balancer Controller using HELM
# Resource: Helm Release for load balancer controller
resource "helm_release" "loadbalancer_controller" {
  depends_on = [
    aws_iam_role.lbc_iam_role
  ]

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"

  # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  set = [
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.lbc_iam_role.arn
    },
    {
      name  = "vpcId"
      value = local.vpc_id
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "clusterName"
      value = local.cluster_id
    }
  ]
}

# Resource: Helm Release for external DNS
resource "helm_release" "external_dns" {
  depends_on = [aws_iam_role.external_dns_role]
  name       = "external-dns"

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "default"

  set = [
    {
      name  = "image.repository"
      value = "registry.k8s.io/external-dns/external-dns"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
      }, {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.external_dns_role.arn
    },
    {
      name  = "provider" # Default is aws (https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)
      value = "aws"
    },
    {
      name  = "policy" # Default is "upsert-only" which means DNS records will not get deleted even equivalent Ingress resources are deleted (https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)
      value = "sync"   # "sync" will ensure that when ingress resource is deleted, equivalent DNS record in Route53 will get deleted
    }
  ]
}

# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   namespace  = "kube-system"
#   repository = "https://kubernetes-sigs.github.io/metrics-server"
#   chart      = "metrics-server"
#   version    = "3.12.1"

#   # set = [
#   #   {
#   #     name  = "args"
#   #     value = "{--cert-dir=/tmp,--secure-port=4443,--kubelet-preferred-address-types=InternalIP\\,ExternalIP\\,Hostname,--kubelet-use-node-status-port,--kubelet-insecure-tls,--metric-resolution=15s}"
#   #   },
#   #   {
#   #     name  = "resources.requests.cpu"
#   #     value = "100m"
#   #   },
#   #   {
#   #     name  = "resources.requests.memory"
#   #     value = "200Mi"
#   #   }
#   # ]
# }
