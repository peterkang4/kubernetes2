resource "aws_eks_cluster" "peter_eks_cluster" {
  name     = var.CLUSTER_NAME
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = [ var.SUBNET1, var.SUBNET2 ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy-Attachment,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController-Attachment,
  ]

  tags          = {
    Name        = "peter-eks-cluster"
    User        = "Peter Kang"
    Project     = "Peter EKS"
  }

}
