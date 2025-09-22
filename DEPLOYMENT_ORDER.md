# EKS 배포 순서 및 API 에러 해결 가이드

## 🚨 API 에러 원인
1. **잘못된 키 파일 경로**: 존재하지 않는 키 파일 참조
2. **Private IP 연결 시도**: Bastion Private IP로 SSH 연결 불가
3. **순환 의존성**: Helm 모듈이 아직 생성되지 않은 리소스 참조

## ✅ 해결된 사항
- [x] 키 파일 경로를 동적 생성된 키로 변경
- [x] Bastion 연결을 Public IP로 변경

## 📋 올바른 배포 순서

### 1단계: 기본 인프라 배포
```bash
terraform apply -target=module.vpc
terraform apply -target=module.bastion
terraform apply -target=module.eks_cluster
```

### 2단계: 노드그룹 및 애드온
```bash
terraform apply -target=module.eks_nodegroup
terraform apply -target=module.eks_addons
terraform apply -target=module.eks_access_entry
```

### 3단계: Helm 및 컨트롤러
```bash
terraform apply -target=module.helm
terraform apply -target=module.metrics_server
terraform apply -target=module.aws_load_balancer_controller
```

### 4단계: 모니터링 스택
```bash
terraform apply -target=module.prometheus
terraform apply -target=module.grafana
terraform apply -target=module.argocd
```

### 5단계: 최종 설정
```bash
terraform apply -target=module.argocd_secrets
```

## 🔧 문제 해결 체크리스트

### Bastion 연결 확인
```bash
# 1. 키 파일 권한 확인
chmod 600 ../bastion-eks-dev.pem

# 2. Bastion SSH 연결 테스트
ssh -i ../bastion-eks-dev.pem ec2-user@<BASTION_PUBLIC_IP>

# 3. EKS 클러스터 접근 확인 (Bastion 내부에서)
aws eks describe-cluster --name eks-dev --region ap-northeast-2
```

### API 에러 발생 시 대응
1. **Terraform 상태 확인**: `terraform state list`
2. **특정 리소스 재생성**: `terraform taint <resource>`
3. **로그 확인**: `terraform apply -auto-approve -no-color 2>&1 | tee deploy.log`

## 🚀 전체 배포 (수정 후)
```bash
terraform apply -auto-approve
```

## 📞 연결 테스트 명령어
```bash
# Bastion 연결
ssh -i ../bastion-eks-dev.pem ec2-user@$(terraform output -raw bastion_public_ip)

# kubectl 설정 (Bastion 내부)
aws eks update-kubeconfig --region ap-northeast-2 --name eks-dev

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods --all-namespaces
```