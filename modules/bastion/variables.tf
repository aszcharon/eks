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

variable "vpc_id" {
  description = "VPC ID where bastion will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion instance"
  type        = string
}

variable "public_key" {
  description = "Public key for SSH access (only used if create_key_pair is false)"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Whether to create a new key pair or use existing public key"
  type        = bool
  default     = true
}