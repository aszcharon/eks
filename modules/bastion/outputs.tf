output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion instance"
  value       = aws_instance.bastion.public_ip
}



output "private_key_parameter_name" {
  description = "AWS Systems Manager parameter name containing the private key"
  value       = aws_ssm_parameter.bastion_private_key.name
}

output "private_key_file_path" {
  description = "Local file path of the generated private key"
  value       = local_file.bastion_private_key.filename
}

output "public_key_file_path" {
  description = "Local file path of the generated public key"
  value       = local_file.bastion_public_key.filename
}

output "ssh_connection_command" {
  description = "Connect to bastion using AWS Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id}"
}

output "bastion_private_ip" {
  description = "Private IP of the bastion instance"
  value       = aws_instance.bastion.private_ip
}



