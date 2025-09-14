#!/bin/bash

# Bastion 접속 스크립트
# 사용법: ./connect-bastion.sh [project-name] [environment]

PROJECT_NAME=${1:-"your-project"}
ENVIRONMENT=${2:-"dev"}

echo "🔑 AWS SSM에서 Private Key 가져오는 중..."
PARAM_NAME="/charon/${PROJECT_NAME}/${ENVIRONMENT}/bastion/private-key"

# Private key 다운로드
aws ssm get-parameter --name "$PARAM_NAME" --with-decryption --query "Parameter.Value" --output text > bastion-key.pem

if [ $? -ne 0 ]; then
    echo "❌ Private Key를 가져올 수 없습니다. AWS 자격증명과 Parameter 이름을 확인하세요."
    exit 1
fi

# 권한 설정
chmod 400 bastion-key.pem

echo "🌐 Bastion Public IP 확인 중..."
# Terraform output에서 IP 가져오기
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)

if [ -z "$BASTION_IP" ]; then
    echo "❌ Bastion Public IP를 찾을 수 없습니다. terraform output을 확인하세요."
    rm -f bastion-key.pem
    exit 1
fi

echo "🚀 Bastion에 접속합니다: $BASTION_IP"
echo "접속 후 Private Key 파일을 삭제합니다..."

# SSH 접속
ssh -i bastion-key.pem ec2-user@$BASTION_IP

# 접속 종료 후 private key 삭제
rm -f bastion-key.pem
echo "🗑️ Private Key 파일이 삭제되었습니다."