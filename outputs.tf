output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_cluster.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.eks_cluster.cluster_version
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks_cluster.cluster_id}"
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.bastion.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion"
  value       = module.bastion.ssh_connection_command
}

output "argocd_info" {
  description = "ArgoCD access information"
  value = {
    url      = module.argocd.argocd_server_url
    username = "admin"
    password = module.argocd.argocd_admin_password
  }
  sensitive = true
}

