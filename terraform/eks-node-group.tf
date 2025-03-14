# EKS Node Group Oluşturma
resource "aws_eks_node_group" "kl_eks_node_group" {
  cluster_name    = aws_eks_cluster.kl_eks_cluster.name
  node_group_name = "kl-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_worker_AmazonEKS_CNI_Policy
  ]
}
