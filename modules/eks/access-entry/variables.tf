variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "bastion_role_arn" {
  description = "ARN of the bastion IAM role"
  type        = string
}

variable "developer_user_arn" {
  description = "ARN of the developer IAM user (optional)"
  type        = string
  default     = ""
}