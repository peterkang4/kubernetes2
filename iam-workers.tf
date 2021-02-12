###########
# DATA
###########

data "aws_iam_policy_document" "data_eks_worker_node_policy" {
  statement {
    effect       = "Allow"
    actions      = ["sts:AssumeRole"]

    principals {
      type       = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


###########
# RESOURCES
###########

resource "aws_iam_role" "worker_node_role" {
  name               = "${var.CLUSTER_NAME}-worker-node-role"
  assume_role_policy = data.aws_iam_policy_document.data_eks_worker_node_policy.json
  tags               = {
    Name             = "peter-eks-cluster"
    User             = "Peter Kang"
    Project          = "Peter EKS"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.worker_node_role.name
}

resource "aws_iam_instance_profile" "worker_node_profile" {
  name = "${var.CLUSTER_NAME}-worker_node_profile"
  role = aws_iam_role.worker_node_role.name
}

