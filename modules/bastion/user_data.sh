#!/bin/bash

# System repository update (first priority)
echo "Updating system repositories..."
dnf clean all
dnf makecache
dnf update -y

# Install basic packages
echo "Installing basic packages..."
dnf install -y mysql postgresql bash-completion unzip curl wget git

# Install kubectl (latest version for EKS 1.32)
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/bin/kubectl

# AWS CLI v2 is pre-installed in AL2023, just update it
echo "Updating AWS CLI..."
/usr/local/bin/aws --version || {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
}

# Install eksctl
echo "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/bin/eksctl
chmod +x /usr/bin/eksctl

# Install Helm (latest stable version)
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
mv /usr/local/bin/helm /usr/bin/helm

# Verify installations
echo "Verifying installations..."
kubectl version --client
eksctl version
helm version --short
aws --version

# Configure EKS kubeconfig (will be executed after cluster creation)
echo "Setting up EKS configuration script..."
cat > /home/ec2-user/configure-eks.sh << EOL
#!/bin/bash
echo "Configuring EKS cluster access..."
aws eks update-kubeconfig --region ${aws_region} --name ${cluster_name}
echo "EKS configuration completed!"
echo "Testing cluster access..."
kubectl get nodes
kubectl get pods --all-namespaces
EOL
chmod +x /home/ec2-user/configure-eks.sh
chown ec2-user:ec2-user /home/ec2-user/configure-eks.sh

# Auto-configure EKS on login
echo "# Auto-configure EKS on first login" >> /home/ec2-user/.bashrc
echo "if [ ! -f ~/.kube/config ] && [ -f ~/configure-eks.sh ]; then" >> /home/ec2-user/.bashrc
echo "  echo 'Configuring EKS cluster access...'" >> /home/ec2-user/.bashrc
echo "  ~/configure-eks.sh" >> /home/ec2-user/.bashrc
echo "fi" >> /home/ec2-user/.bashrc

# Setup SSH key forwarding and local key access
mkdir -p /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Add SSH agent forwarding configuration
echo 'Host *' >> /home/ec2-user/.ssh/config
echo '    ForwardAgent yes' >> /home/ec2-user/.ssh/config
echo '    ServerAliveInterval 60' >> /home/ec2-user/.ssh/config
chmod 600 /home/ec2-user/.ssh/config
chown ec2-user:ec2-user /home/ec2-user/.ssh/config

# Install SSH agent and start it
dnf install -y openssh-clients
systemctl enable ssh-agent
systemctl start ssh-agent

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
eksctl completion bash > /etc/bash_completion.d/eksctl

# Add eksctl alias
echo 'alias e=eksctl' >> /home/ec2-user/.bashrc
echo 'complete -F __start_eksctl e' >> /home/ec2-user/.bashrc
echo 'alias e=eksctl' >> /root/.bashrc
echo 'complete -F __start_eksctl e' >> /root/.bashrc

# Ensure proper permissions
chmod +x /usr/bin/kubectl /usr/bin/helm /usr/bin/eksctl

echo "Bastion setup completed successfully!"