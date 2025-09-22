# EKS Access Entry for Bastion Role
resource "aws_eks_access_entry" "bastion" {
  cluster_name  = var.cluster_name
  principal_arn = var.bastion_role_arn
  type          = "STANDARD"

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-access"
  }
}

# AWS 관리형 정책 연결 (더 안전하고 세분화된 권한)
resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.bastion.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.bastion]
}

# 개발자 사용자 접근 엔트리 (선택사항)
resource "aws_eks_access_entry" "developer_user" {
  count = var.developer_user_arn != "" ? 1 : 0
  
  cluster_name  = var.cluster_name
  principal_arn = var.developer_user_arn
  type          = "STANDARD"

  tags = {
    Name = "${var.project_name}-${var.environment}-developer-access"
  }
}

resource "aws_eks_access_policy_association" "developer_admin" {
  count = var.developer_user_arn != "" ? 1 : 0
  
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.developer_user[0].principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.developer_user]
}