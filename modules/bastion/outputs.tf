output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  description = "Security group ID of the bastion instance"
  value       = aws_security_group.bastion.id
}

output "private_key_parameter_name" {
  description = "AWS Systems Manager parameter name containing the private key"
  value       = var.create_key_pair ? aws_ssm_parameter.bastion_private_key[0].name : null
}

output "ssh_connection_command" {
  description = "SSH command to connect to bastion (requires private key from Parameter Store)"
  value       = "ssh -i <private-key-file> ec2-user@${aws_instance.bastion.public_ip}"
}