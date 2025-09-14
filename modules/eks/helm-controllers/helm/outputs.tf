output "helm_installed" {
  description = "Helm installation status"
  value       = null_resource.verify_helm.id
}