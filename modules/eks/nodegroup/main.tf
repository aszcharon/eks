

resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-${var.environment}-nodes"
  node_role_arn   = var.eks_node_group_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types
  
  # EKS 1.32 호환 AMI 설정
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  # SSH 접근이 필요한 경우에만 활성화
  # remote_access {
  #   ec2_ssh_key = "your-key-name"
  #   source_security_group_ids = [aws_security_group.eks_nodes.id]
  # }



  tags = {
    Name = "${var.project_name}-${var.environment}-node-group"
  }
}