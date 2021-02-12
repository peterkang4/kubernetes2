resource "aws_security_group" "cluster_security_group" {
  name        = "eks-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.VPC_ID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags          = {
    Name        = "peter-eks-cluster"
    User        = "Peter Kang"
    Project     = "Peter EKS"
  }
}

resource "aws_security_group" "node_security_group" {
  name        = "eks-node-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.VPC_ID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags          = {
    Name        = "peter-eks-cluster"
    User        = "Peter Kang"
    Project     = "Peter EKS"
  }
}

resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster_security_group.id
  source_security_group_id = aws_security_group.node_security_group.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks_cluster_ingress_workstation_https" {
  cidr_blocks       = [ "10.0.0.0/16" ]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster_security_group.id
  to_port           = 443
  type              = "ingress"
}

