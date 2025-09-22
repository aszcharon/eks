# EKS Terraform Infrastructure

AWS EKS 클러스터를 Terraform으로 배포하는 완전한 인프라 코드입니다.

## 🏗️ 아키텍처

### 인프라 구성요소
- **VPC**: 192.168.0.0/16 CIDR 블록
- **서브넷**: Public 2개, Private EKS 2개, Private RDS 2개
- **EKS 클러스터**: Kubernetes 1.32
- **노드 그룹**: t3.medium 인스턴스 (Min: 1, Desired: 2, Max: 4)
- **베스천 호스트**: EKS 클러스터 관리용
- **Helm 애드온**: ArgoCD, Grafana, Prometheus, AWS Load Balancer Controller

### EKS 애드온
- VPC CNI: v1.20.0-eksbuild.1
- CoreDNS: v1.11.3-eksbuild.3
- Kube-proxy: v1.32.6-eksbuild.8
- EBS CSI Driver: v1.48.0-eksbuild.2
- Pod Identity Agent: v1.3.8-eksbuild.2

## 🚀 빠른 시작

### 1. 사전 요구사항
```bash
# AWS CLI 설치 및 구성
aws configure

# Terraform 설치 (v1.0+)
terraform --version

# kubectl 설치
kubectl version --client
```

### 2. 저장소 클론
```bash
git clone https://github.com/aszcharon/eks.git
cd eks
```

### 3. 변수 설정
```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 파일을 편집하여 환경에 맞게 수정
```

### 4. 배포
```bash
# Terraform 초기화
terraform init

# 배포 계획 확인
terraform plan

# 인프라 배포 (Helm 제외)
terraform apply -target=module.vpc -target=module.eks_cluster -target=module.eks_nodegroup -target=module.eks_addons -target=module.bastion -target=module.eks_access_entry

# 전체 배포 (Helm 포함)
terraform apply
```

### 5. kubectl 설정
```bash
aws eks --region ap-northeast-2 update-kubeconfig --name eks-dev
kubectl get nodes
```

## 📁 프로젝트 구조

```
eks/
├── modules/
│   ├── vpc/                    # VPC, 서브넷, 보안 그룹
│   ├── eks/
│   │   ├── cluster/           # EKS 클러스터
│   │   ├── nodegroup/         # EKS 노드 그룹
│   │   ├── addons/            # EKS 애드온
│   │   └── access-entry/      # EKS 액세스 엔트리
│   ├── bastion/               # 베스천 호스트
│   └── helm-addons/           # Helm 차트 배포
├── scripts/                   # 유틸리티 스크립트
├── main.tf                    # 메인 Terraform 설정
├── variables.tf               # 변수 정의
├── outputs.tf                 # 출력 값
├── terraform.tfvars.example   # 변수 예제 파일
└── README.md                  # 이 파일
```

## 🔧 주요 변수

| 변수명 | 설명 | 기본값 |
|--------|------|--------|
| `aws_region` | AWS 리전 | `ap-northeast-2` |
| `organization` | 조직명 | `charon` |
| `project_name` | 프로젝트명 | `eks` |
| `environment` | 환경 | `dev` |
| `vpc_cidr` | VPC CIDR 블록 | `192.168.0.0/16` |
| `eks_version` | EKS 버전 | `1.32` |
| `node_instance_types` | 노드 인스턴스 타입 | `["t3.medium"]` |

## 🖥️ 베스천 호스트 접속

### SSH 접속
```bash
ssh -i ../bastion-eks-dev.pem ec2-user@<BASTION_PUBLIC_IP>
```

### SSM 세션 매니저 (권장)
```bash
aws ssm start-session --target <INSTANCE_ID>
```

## 🎯 배포 순서

1. **VPC 및 네트워킹**: 서브넷, 라우팅 테이블, NAT Gateway
2. **IAM 역할**: EKS 클러스터 및 노드 그룹용 역할
3. **EKS 클러스터**: 컨트롤 플레인 생성
4. **노드 그룹**: 워커 노드 배포
5. **EKS 애드온**: 필수 애드온 설치
6. **베스천 호스트**: 관리용 EC2 인스턴스
7. **Helm 애드온**: ArgoCD, 모니터링 도구 등

## 🗑️ 리소스 삭제

```bash
# 전체 인프라 삭제
terraform destroy

# 특정 모듈만 삭제
terraform destroy -target=module.helm_addons
```

## 📊 모니터링

배포 후 다음 도구들을 사용할 수 있습니다:

- **ArgoCD**: GitOps 배포 관리
- **Grafana**: 메트릭 시각화
- **Prometheus**: 메트릭 수집
- **AWS Load Balancer Controller**: 로드 밸런서 관리

## 🔒 보안 고려사항

- 베스천 호스트는 특정 IP에서만 SSH 접근 가능
- EKS 클러스터는 프라이빗 서브넷에 배포
- IAM 역할 기반 액세스 제어
- 보안 그룹으로 네트워크 트래픽 제한

## 🤝 기여하기

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 생성해 주세요.