# Get current IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Security Group for Bastion
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-${var.environment}-bastion-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # EKS API 서버 접근을 위한 규칙
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "charon-${var.project_name}-${var.environment}-bastion-sg"
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Key Pair - Generate dynamically or use existing
resource "tls_private_key" "bastion" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion" {
  key_name   = "charon-${var.project_name}-${var.environment}-bastion-key"
  public_key = var.create_key_pair ? tls_private_key.bastion[0].public_key_openssh : var.public_key
}

# Store private key in AWS Systems Manager Parameter Store (encrypted)
resource "aws_ssm_parameter" "bastion_private_key" {
  count = var.create_key_pair ? 1 : 0
  name  = "/charon/${var.project_name}/${var.environment}/bastion/private-key"
  type  = "SecureString"
  value = tls_private_key.bastion[0].private_key_pem

  tags = {
    Name = "charon-${var.project_name}-${var.environment}-bastion-private-key"
  }
}

# IAM Role for Bastion
resource "aws_iam_role" "bastion" {
  name = "${var.project_name}-${var.environment}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project_name}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# Bastion Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name              = aws_key_pair.bastion.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id             = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              # Amazon Linux 2023 uses dnf instead of yum
              dnf update -y
              dnf install -y mysql postgresql bash-completion unzip
              
              # Install kubectl (latest version for EKS 1.32)
              curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl"
              chmod +x ./kubectl
              mv ./kubectl /usr/bin/kubectl
              
              # AWS CLI v2 is pre-installed in AL2023, just update it
              /usr/local/bin/aws --version || {
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                ./aws/install
              }
              
              # Install helm
              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              mv /usr/local/bin/helm /usr/bin/helm
              
              # Configure PATH and aliases for root user
              echo 'export PATH=/usr/bin:/usr/local/bin:$PATH' >> /root/.bashrc
              echo 'alias k=kubectl' >> /root/.bashrc
              echo 'complete -F __start_kubectl k' >> /root/.bashrc
              
              # Configure PATH and aliases for ec2-user
              echo 'export PATH=/usr/bin:/usr/local/bin:$PATH' >> /home/ec2-user/.bashrc
              echo 'alias k=kubectl' >> /home/ec2-user/.bashrc
              echo 'complete -F __start_kubectl k' >> /home/ec2-user/.bashrc
              chown ec2-user:ec2-user /home/ec2-user/.bashrc
              
              # Setup kubectl completion
              kubectl completion bash > /etc/bash_completion.d/kubectl
              
              # Ensure proper permissions
              chmod +x /usr/bin/kubectl /usr/bin/helm
              EOF

  tags = {
    Name = "charon-${var.project_name}-${var.environment}-bastion"
  }
}