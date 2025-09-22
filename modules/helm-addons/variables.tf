variable "private_key" {
  description = "Private key for bastion host connection"
  type        = string
  sensitive   = true
}

variable "bastion_host" {
  description = "Bastion host IP address"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for EKS"
  type        = string
}

variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}