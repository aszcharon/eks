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

variable "aws_region" {
  description = "AWS region for EKS cluster"
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_name" {
  description = "EKS cluster name for kubeconfig setup"
  type        = string
}

variable "parent_directory" {
  description = "Parent directory path to save generated key files"
  type        = string
  default     = ".."
}

variable "bastion_security_group_id" {
  description = "Security group ID for bastion"
  type        = string
}

variable "bastion_instance_profile_name" {
  description = "Instance profile name for bastion"
  type        = string
}