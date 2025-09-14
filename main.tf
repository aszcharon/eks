module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
}

module "eks_cluster" {
  source = "./modules/eks/cluster"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_eks_subnet_ids
  eks_version        = var.eks_version
}

module "eks_nodegroup" {
  source = "./modules/eks/nodegroup"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  cluster_name              = module.eks_cluster.cluster_id
  cluster_security_group_id = module.eks_cluster.cluster_security_group_id
  private_subnet_ids        = module.vpc.private_eks_subnet_ids
  node_instance_types       = var.node_instance_types
  node_desired_size         = var.node_desired_size
  node_max_size             = var.node_max_size
  node_min_size             = var.node_min_size
}

module "eks_addons" {
  source = "./modules/eks/addons"

  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = module.eks_cluster.cluster_id
  node_group_arn  = module.eks_nodegroup.node_group_arn
}

module "metrics_server" {
  source = "./modules/eks/helm-controllers/metrics-server"

  cluster_endpoint = module.eks_cluster.cluster_endpoint

  depends_on = [module.eks_addons, module.eks_nodegroup]
}

module "prometheus" {
  source = "./modules/eks/helm-controllers/prometheus"

  cluster_endpoint = module.eks_cluster.cluster_endpoint

  depends_on = [module.eks_addons, module.eks_nodegroup]
}

module "grafana" {
  source = "./modules/eks/helm-controllers/grafana"

  prometheus_endpoint = "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"

  depends_on = [module.prometheus, module.eks_addons]
}

module "bastion" {
  source = "./modules/bastion"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  public_key       = var.bastion_public_key
}

module "argocd" {
  source = "./modules/eks/helm-controllers/argocd"

  cluster_endpoint = module.eks_cluster.cluster_endpoint

  depends_on = [module.eks_addons, module.eks_nodegroup]
}