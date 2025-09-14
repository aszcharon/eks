variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "organization" {
  description = "Organization name for resource naming"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}