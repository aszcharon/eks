# EKS Terraform Modules

AWS EKS 클러스터를 Terraform으로 배포하는 모듈화된 구조입니다.

## 🚀 주요 특징

- **EKS 1.32** 최신 버전 지원
- **Amazon Linux 2023** Bastion 호스트
- **Pod Identity Agent** 지원 (EKS 1.32 신규 기능)
- **최적화된 의존성 관리**로 안정적인 Helm 배포
- **완전 자동화된** 인프라 배포

## 📁 구조

```
terraform/
├── main.tf                    # 모든 모듈 호출
├── variables.tf               # 전역 변수
├── outputs.tf                 # 전역 출력
├── versions.tf                # 프로바이더 (AWS 5.80+, Kubernetes 2.35+, Helm 2.17+)
├── terraform.tfvars.example   # 변수 값 예시
└── modules/
    ├── vpc/                   # VPC 모듈
    ├── bastion/               # Amazon Linux 2023 Bastion 호스트
    └── eks/
        ├── cluster/           # EKS 클러스터 (1.32)
        ├── nodegroup/         # EKS 노드그룹 (AL2023)
        ├── addons/            # EKS 애드온 (Pod Identity Agent 포함)
        └── helm-controllers/
            ├── metrics-server/    # Kubernetes 메트릭
            ├── prometheus/        # 메트릭 수집/저장
            ├── grafana/          # 메트릭 시각화
            └── argocd/           # GitOps 배포
```

## 배포 방법

1. **AWS 자격 증명 설정**
```bash
aws configure
```

2. **변수 파일 설정**
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일 수정
```

3. **Terraform 초기화 및 배포**
```bash
terraform init
terraform plan
terraform apply
```

## 🛠️ 포함된 컴포넌트

### 인프라
- **VPC**: 퍼블릭/프라이빗 서브넷, NAT 게이트웨이
- **EKS 클러스터**: Kubernetes 1.32 (최신 버전)
- **EKS 노드그룹**: Amazon Linux 2023 기반 관리형 워커 노드
- **Bastion 호스트**: Amazon Linux 2023, kubectl/helm/aws-cli 사전 설치

### EKS 애드온 (1.32 호환)
- **VPC CNI**: v1.19.0-eksbuild.1
- **CoreDNS**: v1.11.3-eksbuild.2
- **Kube-proxy**: v1.32.0-eksbuild.2
- **EBS CSI Driver**: v1.37.0-eksbuild.1
- **Pod Identity Agent**: v1.3.4-eksbuild.1 (신규)

### Helm 차트
- **Metrics Server**: v3.12.2 (Kubernetes 메트릭)
- **Prometheus**: v66.2.2 (메트릭 수집/저장)
- **Grafana**: v8.8.2 (메트릭 시각화)
- **ArgoCD**: v7.7.11 (GitOps 배포)

## 🔧 접근 방법

### kubectl 설정
```bash
aws eks --region ap-northeast-2 update-kubeconfig --name charon-eks-dev
```

### Bastion 호스트 접근
```bash
# SSH 접속
ssh -i bastion-key ec2-user@<BASTION_PUBLIC_IP>

# kubectl 명령어 (k alias 사용 가능)
k get nodes
kubectl get pods -A
```

### 모니터링 도구 접근

#### Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
# http://localhost:3000 (admin/admin123!)
```

#### Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# http://localhost:9090
```

#### ArgoCD
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:80
# http://localhost:8080
# 초기 비밀번호: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 네이밍 및 태그 규칙

### 네이밍 패턴
```
{organization}-{project_name}-{environment}-{resource_type}
```

**예시:**
- VPC: `charon-eks-dev-vpc`
- EKS Cluster: `charon-eks-dev-cluster`
- Node Group: `charon-eks-dev-nodegroup`

### 공통 태그
모든 리소스에 자동 적용되는 태그:
- **Organization**: charon
- **Project**: eks
- **Environment**: dev/staging/prod
- **Team**: devops
- **CostCenter**: engineering
- **ManagedBy**: terraform
- **CreatedDate**: 생성일자

### 설정 방법
`terraform.tfvars`에서 네이밍 규칙 커스터마이징:
```hcl
organization = "charon"
project_name = "eks"
environment  = "dev"
team         = "devops"
cost_center  = "engineering"

additional_tags = {
  Owner      = "DevOps Team"
  Purpose    = "EKS Development Cluster"
  Monitoring = "enabled"
}
```

## ⚡ 성능 최적화

### EKS 1.32 최적화
- **Pod Identity Agent**: IAM 역할 관리 개선
- **Amazon Linux 2023**: 최신 보안 패치 및 성능 향상
- **GP2 StorageClass**: 안정적인 스토리지 성능
- **최적화된 의존성**: Helm 배포 안정성 향상

### Bastion 호스트 사전 설치 도구
- **kubectl**: v1.32.0 (EKS 버전과 일치)
- **AWS CLI**: v2 (최신 버전)
- **Helm**: v3 (최신 버전)
- **k alias**: kubectl 단축 명령어
- **bash completion**: 자동완성 지원

## 🔍 문제 해결

### Helm 배포 실패 시
```bash
# EKS 애드온 상태 확인
aws eks describe-addon --cluster-name etech-eks-dev --addon-name vpc-cni

# 노드 상태 확인
kubectl get nodes
kubectl describe nodes
```

### StorageClass 문제 시
```bash
# 기본 StorageClass 확인
kubectl get storageclass

# EBS CSI 드라이버 확인
kubectl get pods -n kube-system | grep ebs-csi
```

자세한 네이밍 규칙은 [NAMING_CONVENTION.md](./NAMING_CONVENTION.md)를 참조하세요.