resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-cni"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"
  
  depends_on = [var.node_group_arn]
  
  tags = {
    Name = "${var.project_name}-${var.environment}-coredns"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = var.cluster_name
  addon_name   = "kube-proxy"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-kube-proxy"
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = var.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-ebs-csi-driver"
  }
}