resource "aws_iam_openid_connect_provider" "cluster" {
  depends_on = [
    aws_eks_cluster.this
  ]
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
