output "vpc_cni_arn" {
  description = "VPC CNI addon ARN"
  value       = aws_eks_addon.vpc_cni.arn
}

output "coredns_arn" {
  description = "CoreDNS addon ARN"
  value       = aws_eks_addon.coredns.arn
}

output "kube_proxy_arn" {
  description = "Kube-proxy addon ARN"
  value       = aws_eks_addon.kube_proxy.arn
}

output "ebs_csi_driver_arn" {
  description = "EBS CSI driver addon ARN"
  value       = aws_eks_addon.ebs_csi_driver.arn
}