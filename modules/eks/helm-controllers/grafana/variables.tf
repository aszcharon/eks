variable "prometheus_endpoint" {
  description = "Prometheus endpoint for dependency"
  type        = string
}

variable "grafana_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "7.0.19"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123!"
  sensitive   = true
}