resource "aws_eks_addon" "vpc_cni" {
  cluster_name                    = var.cluster_name
  addon_name                      = "vpc-cni"
  addon_version                   = "v1.19.0-eksbuild.1"
  resolve_conflicts_on_create     = "OVERWRITE"
  resolve_conflicts_on_update     = "OVERWRITE"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-cni"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name                    = var.cluster_name
  addon_name                      = "coredns"
  addon_version                   = "v1.11.3-eksbuild.2"
  resolve_conflicts_on_create     = "OVERWRITE"
  resolve_conflicts_on_update     = "OVERWRITE"
  
  depends_on = [var.node_group_arn]
  
  tags = {
    Name = "${var.project_name}-${var.environment}-coredns"
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                    = var.cluster_name
  addon_name                      = "kube-proxy"
  addon_version                   = "v1.32.0-eksbuild.2"
  resolve_conflicts_on_create     = "OVERWRITE"
  resolve_conflicts_on_update     = "OVERWRITE"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-kube-proxy"
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                    = var.cluster_name
  addon_name                      = "aws-ebs-csi-driver"
  addon_version                   = "v1.37.0-eksbuild.1"
  resolve_conflicts_on_create     = "OVERWRITE"
  resolve_conflicts_on_update     = "OVERWRITE"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-ebs-csi-driver"
  }
}

# EKS 1.32에서 추가된 Pod Identity Agent
resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                    = var.cluster_name
  addon_name                      = "eks-pod-identity-agent"
  addon_version                   = "v1.3.4-eksbuild.1"
  resolve_conflicts_on_create     = "OVERWRITE"
  resolve_conflicts_on_update     = "OVERWRITE"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-pod-identity-agent"
  }
}