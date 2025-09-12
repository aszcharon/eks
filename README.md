# EKS Terraform Modules

AWS EKS 클러스터를 Terraform으로 배포하는 모듈화된 구조입니다.

## 구조

```
terraform/
├── main.tf                    # 모든 모듈 호출
├── variables.tf               # 전역 변수
├── outputs.tf                 # 전역 출력
├── versions.tf                # 프로바이더 (AWS, Kubernetes, Helm)
├── terraform.tfvars.example   # 변수 값 예시
└── modules/
    ├── vpc/                   # VPC 모듈
    └── eks/
        ├── cluster/           # EKS 클러스터
        ├── nodegroup/         # EKS 노드그룹  
        ├── addons/            # EKS 애드온
        └── helm-controllers/
            ├── metrics-server/    # 기본 메트릭
            ├── prometheus/        # 메트릭 수집/저장
            └── grafana/          # 메트릭 시각화
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

## 포함된 컴포넌트

- **VPC**: 퍼블릭/프라이빗 서브넷, NAT 게이트웨이
- **EKS 클러스터**: Kubernetes 1.28
- **EKS 노드그룹**: 관리형 워커 노드
- **EKS 애드온**: VPC CNI, CoreDNS, Kube-proxy, EBS CSI
- **Metrics Server**: 기본 메트릭 수집
- **Prometheus**: 상세 메트릭 수집 및 저장
- **Grafana**: 메트릭 시각화 대시보드

## 접근 방법

### kubectl 설정
```bash
aws eks --region ap-northeast-2 update-kubeconfig --name etech-eks-dev
```

### Grafana 접근
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
# http://localhost:3000 (admin/admin123!)
```

### Prometheus 접근
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# http://localhost:9090
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

자세한 네이밍 규칙은 [NAMING_CONVENTION.md](./NAMING_CONVENTION.md)를 참조하세요.