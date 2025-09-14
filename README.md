# EKS Terraform 인프라

GitOps 기반 모니터링 및 배포 도구가 포함된 완전한 Amazon EKS 클러스터 Terraform 인프라입니다.

## 🏗️ 아키텍처

### 핵심 인프라
- **VPC**: 다중 AZ에 걸친 퍼블릭/프라이빗 서브넷이 있는 커스텀 VPC
- **EKS 클러스터**: OIDC 프로바이더가 포함된 관리형 Kubernetes 클러스터
- **노드 그룹**: 프라이빗 서브넷의 관리형 워커 노드
- **Bastion 호스트**: 클러스터 관리를 위한 보안 접근 지점

### Helm 컨트롤러 및 모니터링
- **ArgoCD**: LoadBalancer 접근이 가능한 GitOps 지속적 배포
- **Prometheus**: 모니터링 및 알림 스택
- **Grafana**: Prometheus 통합 시각화 대시보드
- **Metrics Server**: HPA를 위한 리소스 모니터링

### 보안 및 접근
- **IAM 역할**: EKS 구성 요소를 위한 적절한 RBAC
- **보안 그룹**: 최소 권한 네트워크 접근
- **자동 생성 시크릿**: ArgoCD 자격 증명이 bastion에 저장됨

## 🚀 빠른 시작

### 사전 요구사항
- 적절한 권한으로 구성된 AWS CLI
- Terraform >= 1.0
- kubectl
- bastion 접근을 위한 SSH 키 페어

### 배포

1. **클론 및 구성**
```bash
git clone https://github.com/aszcharon/eks.git
cd eks
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 수정하세요
```

2. **인프라 배포**
```bash
terraform init
terraform plan
terraform apply
```

3. **클러스터 접근**
```bash
# kubectl 구성
aws eks --region ap-northeast-2 update-kubeconfig --name <cluster-name>

# bastion 연결
ssh -i ~/.ssh/id_rsa ec2-user@<bastion-ip>

# ArgoCD 자격 증명 확인
cat /home/ec2-user/argo_secrets
```

## 📋 설정

### 필수 변수
```hcl
aws_region = "ap-northeast-2"
organization = "charon"
project_name = "blog"
environment = "dev"
bastion_public_key = "ssh-rsa AAAAB3..."
```

### 선택적 변수
```hcl
vpc_cidr = "10.0.0.0/16"
eks_version = "1.28"
node_instance_types = ["t3.medium"]
node_desired_size = 2
node_max_size = 4
node_min_size = 1
```

## 🔧 설치된 구성 요소

### 설치 순서
1. **핵심 EKS** → VPC, 클러스터, 노드, 애드온
2. **Helm** → 설치 및 검증
3. **모니터링 스택** → ArgoCD, Prometheus, Grafana (병렬)
4. **시크릿** → ArgoCD 자격 증명을 bastion에 저장
5. **Metrics Server** → 리소스 모니터링

### 접근 URL
배포 후 LoadBalancer를 통해 서비스에 접근:
- **ArgoCD**: `http://<alb-hostname>` (자격 증명은 `/home/ec2-user/argo_secrets`에 있음)
- **Prometheus**: `http://<prometheus-alb>`
- **Grafana**: `http://<grafana-alb>` (admin/admin123!)

## 🔐 보안 기능

- **프라이빗 서브넷**: 워커 노드가 인터넷에서 격리됨
- **Bastion 접근**: 클러스터 관리를 위한 보안 점프 호스트
- **IAM 통합**: AWS IAM과의 적절한 RBAC
- **네트워크 정책**: 최소 권한 보안 그룹
- **자동 생성 시크릿**: 보안 자격 증명 관리

## 📊 모니터링 및 GitOps

### Prometheus 스택
- **메트릭 수집**: 클러스터 및 애플리케이션 메트릭
- **알림**: 알림을 위한 AlertManager
- **Grafana 통합**: 사전 구성된 대시보드

### ArgoCD GitOps
- **저장소 모니터링**: Git에서 자동 배포
- **동기화 정책**: 선언적 애플리케이션 관리
- **웹 UI**: 시각적 배포 관리
- **CLI 접근**: 명령줄 GitOps 작업

## 🔗 관련 저장소

- **애플리케이션**: [aszcharon/blog](https://github.com/aszcharon/blog) - CI/CD가 포함된 Spring Boot 앱
- **매니페스트**: [aszcharon/manifest](https://github.com/aszcharon/manifest) - Kubernetes 배포

## 📤 출력

```bash
# 모든 출력 확인
terraform output

# 특정 출력
terraform output configure_kubectl
terraform output bastion_ssh_command
terraform output -json argocd_info
```

## 🧹 정리

```bash
# 먼저 Kubernetes 리소스 삭제
kubectl delete all --all -n charon-blog

# 인프라 삭제
terraform destroy
```

## 🔍 문제 해결

### 일반적인 문제

**ArgoCD 접근 불가**
```bash
# LoadBalancer 상태 확인
kubectl get svc -n argocd
kubectl describe svc argocd-server -n argocd
```

**Helm 설치 실패**
```bash
# bastion 연결 확인
ssh -i ~/.ssh/id_rsa ec2-user@<bastion-ip> "helm version"
```

**노드 그룹 문제**
```bash
# 노드 상태 확인
kubectl get nodes
kubectl describe nodes
```

### 유용한 명령어

```bash
# 클러스터 상태
kubectl get componentstatuses
kubectl get pods -n kube-system

# ArgoCD CLI 로그인
argocd login <argocd-url> --username admin --password <password> --insecure

# Prometheus 대상
kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-prometheus 9090:9090
```

## 🤝 기여

기여할 때는 `NAMING_CONVENTION.md`의 네이밍 규칙을 따라주세요.