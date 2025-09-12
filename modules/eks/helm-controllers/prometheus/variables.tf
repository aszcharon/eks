variable "cluster_endpoint" {
  description = "EKS cluster endpoint for dependency"
  type        = string
}

variable "prometheus_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "55.5.0"
}