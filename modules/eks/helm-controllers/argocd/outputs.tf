output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = "Access via LoadBalancer or kubectl port-forward: kubectl port-forward -n argocd svc/argocd-server 8080:443"
}

output "argocd_admin_password" {
  description = "ArgoCD admin password command"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  sensitive   = true
}