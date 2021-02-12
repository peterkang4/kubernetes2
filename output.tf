output "eks_cluster_endpoint" {
  value = aws_eks_cluster.peter_eks_cluster.endpoint
}

output "worker_node_role_arn" {
  description = "IAM role ARN used by nodes."
  value       = aws_iam_role.worker_node_role.arn
}

output "worker_node_role_id" {
  description = "IAM role ID used by nodes."
  value       = aws_iam_role.worker_node_role.id
}

output "eks_node_group" {
  description = "Outputs from EKS node group. See `aws_eks_node_group` Terraform documentation for values"
  value       = aws_eks_node_group.eks_node_group
}