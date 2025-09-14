output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = base64decode(data.kubernetes_secret.argocd_initial_admin_secret.data.password)
  sensitive   = true
}