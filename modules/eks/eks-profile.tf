# resource "aws_eks_fargate_profile" "kube-system" {
#   cluster_name           = aws_eks_cluster.cluster.name
#   fargate_profile_name   = "kube-system"
#   pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn

#   # These subnets must have the following resource tag: 
#   # kubernetes.io/cluster/<CLUSTER_NAME>.
#   subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

#   selector {
#     namespace = "kube-system"
#   }
# }

# data "aws_eks_cluster_auth" "eks" {
#   name = aws_eks_cluster.cluster.id
# }

# resource "null_resource" "k8s_patcher" {
#   depends_on = [aws_eks_fargate_profile.kube-system]

#   triggers = {
#     endpoint = aws_eks_cluster.cluster.endpoint
#     ca_crt   = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
#     token    = data.aws_eks_cluster_auth.eks.token
#   }

#   provisioner "local-exec" {
#     command = <<EOH
# cat >/tmp/ca.crt <<EOF
# ${base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)}
# EOF
# kubectl \
#   --server="${aws_eks_cluster.cluster.endpoint}" \
#   --certificate_authority=/tmp/ca.crt \
#   --token="${data.aws_eks_cluster_auth.eks.token}" \
#   patch deployment coredns \
#   -n kube-system --type json \
#   -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
# EOH
#   }

#   lifecycle {
#     ignore_changes = [triggers]
#   }
# }

# resource "aws_eks_fargate_profile" "app_profile" {
#   cluster_name           = aws_eks_cluster.cluster.name
#   fargate_profile_name   = var.environment
#   pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn

#   # These subnets must have the following resource tag: 
#   # kubernetes.io/cluster/<CLUSTER_NAME>.
#   subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

#   selector {
#     namespace = var.environment
#   }
# }
