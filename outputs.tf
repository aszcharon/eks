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

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = "admin123!"
  sensitive   = true
}

output "monitoring_info" {
  description = "Monitoring stack information"
  value = {
    prometheus_url = "Access via kubectl port-forward: kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
    grafana_url    = "Access via LoadBalancer or kubectl port-forward: kubectl port-forward -n monitoring svc/grafana 3000:80"
  }
}

output "argocd_info" {
  description = "ArgoCD access information"
  value = {
    server_url = module.argocd.argocd_server_url
    admin_password_command = module.argocd.argocd_admin_password
  }
  sensitive = true
}