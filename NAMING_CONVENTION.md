# 네이밍 규칙 및 태그 가이드

## 🏷️ 네이밍 규칙

### 기본 패턴
```
{organization}-{project_name}-{environment}-{resource_type}
```

### 예시
- VPC: `charon-eks-dev-vpc`
- EKS Cluster: `charon-eks-dev-cluster`
- Node Group: `charon-eks-dev-nodegroup`
- Security Group: `charon-eks-dev-sg-cluster`

## 📋 공통 태그

모든 리소스에 자동으로 적용되는 태그:

| 태그 키 | 설명 | 예시 값 |
|---------|------|---------|
| Organization | 조직명 | charon |
| Project | 프로젝트명 | eks |
| Environment | 환경 | dev/staging/prod |
| Team | 담당팀 | devops |
| CostCenter | 비용센터 | engineering |
| ManagedBy | 관리도구 | terraform |
| CreatedDate | 생성일 | 2024-01-15 |

## ⚙️ 설정 방법

### terraform.tfvars 수정
```hcl
# 기본 네이밍
organization = "charon"
project_name = "eks"
environment  = "dev"
team         = "devops"
cost_center  = "engineering"

# 추가 태그
additional_tags = {
  Owner       = "DevOps Team"
  Purpose     = "EKS Development Cluster"
  Backup      = "daily"
  Monitoring  = "enabled"
}
```

### 환경별 설정 예시

**개발환경 (dev)**
```hcl
environment = "dev"
additional_tags = {
  Purpose = "Development and Testing"
  Backup  = "weekly"
}
```

**운영환경 (prod)**
```hcl
environment = "prod"
additional_tags = {
  Purpose     = "Production Workloads"
  Backup      = "daily"
  Monitoring  = "critical"
  Compliance  = "required"
}
```

## 🔧 리소스별 네이밍

### VPC 관련
- VPC: `{name_prefix}-vpc`
- Public Subnet: `{name_prefix}-public-{az}`
- Private Subnet: `{name_prefix}-private-{az}`
- Internet Gateway: `{name_prefix}-igw`
- NAT Gateway: `{name_prefix}-nat-{az}`

### EKS 관련
- Cluster: `{name_prefix}-cluster`
- Node Group: `{name_prefix}-nodegroup`
- Security Group: `{name_prefix}-sg-{purpose}`
- IAM Role: `{name_prefix}-role-{purpose}`

### 모니터링
- Namespace: `monitoring`
- Prometheus: `prometheus-{name_prefix}`
- Grafana: `grafana-{name_prefix}`

## 📝 네이밍 규칙 준수사항

1. **소문자 사용**: 모든 리소스명은 소문자 사용
2. **하이픈 구분**: 단어 구분은 하이픈(-) 사용
3. **일관성 유지**: 모든 환경에서 동일한 패턴 적용
4. **길이 제한**: AWS 리소스 이름 제한 고려 (최대 63자)
5. **특수문자 금지**: 알파벳, 숫자, 하이픈만 사용