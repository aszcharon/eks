# EKS Terraform Infrastructure

Complete Terraform infrastructure for Amazon EKS cluster with GitOps-ready monitoring and deployment tools.

## 🏗️ Architecture

### Core Infrastructure
- **VPC**: Custom VPC with public/private subnets across multiple AZs
- **EKS Cluster**: Managed Kubernetes cluster with OIDC provider
- **Node Groups**: Managed worker nodes in private subnets
- **Bastion Host**: Secure access point for cluster management

### Helm Controllers & Monitoring
- **ArgoCD**: GitOps continuous deployment with LoadBalancer access
- **Prometheus**: Monitoring and alerting stack
- **Grafana**: Visualization dashboard with Prometheus integration
- **Metrics Server**: Resource monitoring for HPA

### Security & Access
- **IAM Roles**: Proper RBAC for EKS components
- **Security Groups**: Least privilege network access
- **Auto-generated Secrets**: ArgoCD credentials saved to bastion

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- SSH key pair for bastion access

### Deployment

1. **Clone and configure**
```bash
git clone https://github.com/aszcharon/eks.git
cd eks
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

2. **Deploy infrastructure**
```bash
terraform init
terraform plan
terraform apply
```

3. **Access cluster**
```bash
# Configure kubectl
aws eks --region ap-northeast-2 update-kubeconfig --name <cluster-name>

# Connect to bastion
ssh -i ~/.ssh/id_rsa ec2-user@<bastion-ip>

# Check ArgoCD credentials
cat /home/ec2-user/argo_secrets
```

## 📋 Configuration

### Required Variables
```hcl
aws_region = "ap-northeast-2"
organization = "charon"
project_name = "blog"
environment = "dev"
bastion_public_key = "ssh-rsa AAAAB3..."
```

### Optional Variables
```hcl
vpc_cidr = "10.0.0.0/16"
eks_version = "1.28"
node_instance_types = ["t3.medium"]
node_desired_size = 2
node_max_size = 4
node_min_size = 1
```

## 🔧 Installed Components

### Installation Order
1. **Core EKS** → VPC, Cluster, Nodes, Add-ons
2. **Helm** → Installation and verification
3. **Monitoring Stack** → ArgoCD, Prometheus, Grafana (parallel)
4. **Secrets** → ArgoCD credentials to bastion
5. **Metrics Server** → Resource monitoring

### Access URLs
After deployment, access services via LoadBalancer:
- **ArgoCD**: `http://<alb-hostname>` (credentials in `/home/ec2-user/argo_secrets`)
- **Prometheus**: `http://<prometheus-alb>`
- **Grafana**: `http://<grafana-alb>` (admin/admin123!)

## 🔐 Security Features

- **Private Subnets**: Worker nodes isolated from internet
- **Bastion Access**: Secure jump host for cluster management
- **IAM Integration**: Proper RBAC with AWS IAM
- **Network Policies**: Security groups with least privilege
- **Auto-generated Secrets**: Secure credential management

## 📊 Monitoring & GitOps

### Prometheus Stack
- **Metrics Collection**: Cluster and application metrics
- **Alerting**: AlertManager for notifications
- **Grafana Integration**: Pre-configured dashboards

### ArgoCD GitOps
- **Repository Monitoring**: Automatic deployment from Git
- **Sync Policies**: Declarative application management
- **Web UI**: Visual deployment management
- **CLI Access**: Command-line GitOps operations

## 🔗 Related Repositories

- **Application**: [aszcharon/blog](https://github.com/aszcharon/blog) - Spring Boot app with CI/CD
- **Manifests**: [aszcharon/manifest](https://github.com/aszcharon/manifest) - Kubernetes deployments

## 📤 Outputs

```bash
# Get all outputs
terraform output

# Specific outputs
terraform output configure_kubectl
terraform output bastion_ssh_command
terraform output -json argocd_info
```

## 🧹 Cleanup

```bash
# Delete Kubernetes resources first
kubectl delete all --all -n charon-blog

# Destroy infrastructure
terraform destroy
```

## 🔍 Troubleshooting

### Common Issues

**ArgoCD not accessible**
```bash
# Check LoadBalancer status
kubectl get svc -n argocd
kubectl describe svc argocd-server -n argocd
```

**Helm installation fails**
```bash
# Check bastion connectivity
ssh -i ~/.ssh/id_rsa ec2-user@<bastion-ip> "helm version"
```

**Node group issues**
```bash
# Check node status
kubectl get nodes
kubectl describe nodes
```

### Useful Commands

```bash
# Cluster health
kubectl get componentstatuses
kubectl get pods -n kube-system

# ArgoCD CLI login
argocd login <argocd-url> --username admin --password <password> --insecure

# Prometheus targets
kubectl port-forward -n prometheus svc/prometheus-kube-prometheus-prometheus 9090:9090
```

## 🤝 Contributing

Follow the naming conventions in `NAMING_CONVENTION.md` when contributing.