variable "cluster_endpoint" {
  description = "EKS cluster endpoint for dependency"
  type        = string
}

variable "metrics_server_version" {
  description = "Metrics Server Helm chart version"
  type        = string
  default     = "3.12.2"
}