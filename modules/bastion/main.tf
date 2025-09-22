

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Key Pair - Always generate dynamically
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "charon-${var.project_name}-${var.environment}-bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

# Store private key in AWS Systems Manager Parameter Store (encrypted)
resource "aws_ssm_parameter" "bastion_private_key" {
  name  = "/charon/${var.project_name}/${var.environment}/bastion/private-key"
  type  = "SecureString"
  value = tls_private_key.bastion.private_key_pem

  tags = {
    Name = "charon-${var.project_name}-${var.environment}-bastion-private-key"
  }
}

# Save private key to local file in parent directory
resource "local_file" "bastion_private_key" {
  content  = tls_private_key.bastion.private_key_pem
  filename = "${var.parent_directory}/bastion-${var.project_name}-${var.environment}.pem"
  file_permission = "0600"
}

# Save public key to local file in parent directory
resource "local_file" "bastion_public_key" {
  content  = tls_private_key.bastion.public_key_openssh
  filename = "${var.parent_directory}/bastion-${var.project_name}-${var.environment}.pub"
  file_permission = "0644"
}



# Bastion Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [var.bastion_security_group_id]
  subnet_id             = var.public_subnet_id
  iam_instance_profile   = var.bastion_instance_profile_name

  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    cluster_name = var.cluster_name
    aws_region   = var.aws_region
  })

  tags = {
    Name = "charon-${var.project_name}-${var.environment}-bastion"
  }
}