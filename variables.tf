variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "etech-eks"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

# Naming and Tagging
variable "organization" {
  description = "Organization name for resource naming"
  type        = string
  default     = "charon"
}

variable "team" {
  description = "Team name responsible for resources"
  type        = string
  default     = "devops"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "bastion_public_key" {
  description = "Public key for Bastion server SSH access (only used if create_bastion_key_pair is false)"
  type        = string
  default     = ""
}

variable "create_bastion_key_pair" {
  description = "Whether to create a new key pair for bastion or use existing public key"
  type        = bool
  default     = true
}

variable "developer_user_arn" {
  description = "ARN of the developer IAM user for EKS access (optional)"
  type        = string
  default     = ""
}

# Naming convention: {organization}-{project_name}-{environment}-{resource_type}
locals {
  name_prefix = "${var.organization}-${var.project_name}-${var.environment}"
  
  common_tags = merge({
    Organization = var.organization
    Project      = var.project_name
    Environment  = var.environment
    Team         = var.team
    CostCenter   = var.cost_center
    ManagedBy    = "terraform"
    CreatedDate  = formatdate("YYYY-MM-DD", timestamp())
  }, var.additional_tags)
}