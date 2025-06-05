# Add-on: VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

# Add-on: kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

# Add-on: CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
}

# resource "aws_eks_addon" "guardduty" {
#   cluster_name  = aws_eks_cluster.this.name
#   addon_name    = "aws-guardduty-agent"
#   addon_version = "v1.10.0-eksbuild.2"

#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

#   preserve = true
# }
