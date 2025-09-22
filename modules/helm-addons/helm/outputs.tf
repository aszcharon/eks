output "helm_installed" {
  description = "Helm installation status"
  value       = null_resource.configure_kubectl.id
}