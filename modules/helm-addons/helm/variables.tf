variable "private_key" {
  description = "Private key for SSH connection to bastion"
  type        = string
  sensitive   = true
}

variable "bastion_host" {
  description = "Bastion host IP address"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}