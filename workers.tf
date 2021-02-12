data "aws_ami" "data_eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.peter_eks_cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.peter_eks_cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.peter_eks_cluster.certificate_authority[0].data}' '${var.CLUSTER_NAME}'
USERDATA

}

# resource "aws_launch_configuration" "worker_launch_config" {
#   associate_public_ip_address = true
#   iam_instance_profile = aws_iam_instance_profile.worker_node_profile.name
#   image_id = data.aws_ami.data_eks_worker.id
#   instance_type = "t3.medium"
#   name_prefix = "peter-tf-eks"
#   security_groups = [ aws_security_group.node_security_group.id ]
#   user_data_base64 = base64encode(local.worker-node-userdata)

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "worker_autoscaling_group" {
#   desired_capacity = 2
#   launch_configuration = aws_launch_configuration.worker_launch_config.id
#   max_size = 2
#   min_size = 1
#   name = "worker-autoscaling-group"
#   vpc_zone_identifier = [ var.SUBNET1, var.SUBNET2 ]
#   #vpc_zone_identifier = module.vpc.public_subnets

  # tag {
  #   key = "Name"
  #   value = "eks-worker-asg"
  #   propagate_at_launch = true
  # }

  # tag {
  #   key = "kubernetes.io/cluster/${var.CLUSTER_NAME}"
  #   value = "owned"
  #   propagate_at_launch = true
  # }
# }

#################

# Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.CLUSTER_NAME
  node_group_name = "${var.CLUSTER_NAME}-node-group"
  node_role_arn   = aws_iam_role.worker_node_role.arn
  subnet_ids      = [ var.SUBNET1, var.SUBNET2 ]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }
  
  # dynamic "remote_access" {
  #   for_each = var.ec2_ssh_key != null && var.ec2_ssh_key != "" ? ["true"] : []
  #   content {
  #     ec2_ssh_key               = var.ec2_ssh_key
  #     source_security_group_ids = var.source_security_group_ids
  #   }
  # }

  # launch_template {
  #   id = aws_launch_template.eks_launch_template.id
  #   version = "default"
  # }

  # dynamic "launch_template" {
  #   for_each = length(var.launch_template) == 0 ? [] : [var.launch_template]
  #   content {
  #     id      = lookup(launch_template.value, "id", null)
  #     name    = lookup(launch_template.value, "name", null)
  #     version = lookup(launch_template.value, "version")
  #   }
  # }

  lifecycle {
    create_before_destroy = true
    # ignore_changes        = [ scaling_config.0.desired_size ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_attachment,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_attachment,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_attachment,
  ]
}

# resource "aws_launch_template" "eks_launch_template" {
#   name = "${var.CLUSTER_NAME}-launch-template"

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       volume_size = 20
#     }
#   }

#   capacity_reservation_specification {
#     capacity_reservation_preference = "open"
#   }

#   cpu_options {
#     core_count       = 4
#     threads_per_core = 2
#   }

#   credit_specification {
#     cpu_credits = "standard"
#   }

#   disable_api_termination = false

#   ebs_optimized = true

#   elastic_gpu_specifications {
#     type = "t2.medium"
#   }

#   elastic_inference_accelerator {
#     type = "eia1.medium"
#   }

#   iam_instance_profile {
#     name = aws_iam_instance_profile.worker_node_profile.name
#   }

#   image_id = data.aws_ami.data_eks_worker.id

#   instance_initiated_shutdown_behavior = "terminate"

#   # instance_market_options {
#   #   market_type = "spot"
#   # }

#   instance_type = "t2.medium"

#   kernel_id = "default"

#   key_name = "test"

#   # license_specification {
#   #   license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
#   # }

#   metadata_options {
#     http_endpoint               = "enabled"
#     http_tokens                 = "required"
#     http_put_response_hop_limit = 1
#   }

#   monitoring {
#     enabled = true
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#   }

#   placement {
#     availability_zone = "us-east-1a"
#   }

#   ram_disk_id = "default"

#   vpc_security_group_ids = [ aws_security_group.node_security_group.id ]

#   tag_specifications {
#     resource_type = "instance"

#   tags               = {
#     Name             = "peter-eks-cluster"
#     User             = "Peter Kang"
#     Project          = "Peter EKS"
#   }

#   }

#   user_data = base64encode(local.worker-node-userdata)
# }

