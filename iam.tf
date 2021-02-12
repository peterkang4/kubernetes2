###########
# DATA
###########

data "aws_iam_policy_document" "data_eks_cluster_policy" {
  statement {
    effect       = "Allow"
    actions      = ["sts:AssumeRole"]

    principals {
      type       = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "data_eks_access_policy" {
  statement {
    effect   = "Allow"
    actions  = [
      "eks:*"
    ]
    resources = ["*"]
  }
}

###########
# RESOURCES
###########

resource "aws_iam_policy" "eks_access_policy" {
    name = "${var.CLUSTER_NAME}-eks_access_policy"
    policy = data.aws_iam_policy_document.data_eks_access_policy.json
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.CLUSTER_NAME}-role"
  assume_role_policy = data.aws_iam_policy_document.data_eks_cluster_policy.json
  tags               = {
    Name             = "peter-eks-cluster"
    User             = "Peter Kang"
    Project          = "Peter EKS"
  }
}

# Managed Policy
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy-Attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# Managed Policy
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController-Attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}

# TF Role-Policy
resource "aws_iam_role_policy_attachment" "eks_access_role_policy-Attachment" {
  policy_arn = aws_iam_policy.eks_access_policy.arn
  role       = aws_iam_role.cluster_role.name
}

