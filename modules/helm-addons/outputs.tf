output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = module.argocd.argocd_server_url
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = module.argocd.argocd_admin_password
  sensitive   = true
}