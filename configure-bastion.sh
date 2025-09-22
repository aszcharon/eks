#!/bin/bash

# Bastion 인스턴스에 kubeconfig 설정 스크립트
CLUSTER_NAME="eks-dev"
REGION="ap-northeast-2"
BASTION_IP=$1

if [ -z "$BASTION_IP" ]; then
    echo "Usage: $0 <bastion-ip>"
    exit 1
fi

echo "Configuring kubeconfig on bastion instance..."

# SSH를 통해 bastion에서 kubeconfig 설정
ssh -i "../bastion-eks-dev.pem" ec2-user@$BASTION_IP << 'EOF'
# Update kubeconfig
aws eks update-kubeconfig --region ap-northeast-2 --name eks-dev

# Test kubectl access
kubectl get nodes
kubectl get pods -A

echo "Kubeconfig configured successfully!"
EOF

echo "Bastion configuration completed!"