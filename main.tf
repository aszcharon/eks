module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  organization = var.organization
  project_name = var.project_name
  environment  = var.environment
}

module "eks_cluster" {
  source = "./modules/eks/cluster"

  organization                   = var.organization
  project_name                   = var.project_name
  environment                    = var.environment
  vpc_id                         = module.vpc.vpc_id
  public_subnet_ids              = module.vpc.public_subnet_ids
  private_subnet_ids             = module.vpc.private_eks_subnet_ids
  eks_version                    = var.eks_version
  eks_cluster_role_arn           = module.vpc.eks_cluster_role_arn
  eks_cluster_security_group_id  = module.vpc.eks_cluster_security_group_id
}

module "eks_nodegroup" {
  source = "./modules/eks/nodegroup"

  organization             = var.organization
  project_name             = var.project_name
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  cluster_name             = module.eks_cluster.cluster_id
  private_subnet_ids       = module.vpc.private_eks_subnet_ids
  node_instance_types      = var.node_instance_types
  node_desired_size        = var.node_desired_size
  node_max_size            = var.node_max_size
  node_min_size            = var.node_min_size
  eks_node_group_role_arn  = module.vpc.eks_node_group_role_arn
}

module "eks_addons" {
  source = "./modules/eks/addons"

  organization    = var.organization
  project_name    = var.project_name
  environment     = var.environment
  cluster_name    = module.eks_cluster.cluster_id
  node_group_arn  = module.eks_nodegroup.node_group_arn
}

module "bastion" {
  source = "./modules/bastion"

  organization                   = var.organization
  project_name                   = var.project_name
  environment                    = var.environment
  vpc_id                         = module.vpc.vpc_id
  public_subnet_id               = module.vpc.public_subnet_ids[0]
  aws_region                     = var.aws_region
  cluster_name                   = module.eks_cluster.cluster_id
  parent_directory               = ".."
  bastion_security_group_id      = module.vpc.bastion_security_group_id
  bastion_instance_profile_name  = module.vpc.bastion_instance_profile_name
}

module "eks_access_entry" {
  source = "./modules/eks/access-entry"

  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = module.eks_cluster.cluster_id
  bastion_role_arn   = module.vpc.bastion_role_arn
  developer_user_arn = var.developer_user_arn

  depends_on = [module.eks_cluster, module.bastion]
}

module "helm_addons" {
  source = "./modules/helm-addons"

  private_key       = file("../bastion-eks-dev.pem")
  bastion_host      = module.bastion.bastion_public_ip
  cluster_endpoint  = module.eks_cluster.cluster_endpoint
  cluster_name      = module.eks_cluster.cluster_id
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_issuer       = module.eks_cluster.oidc_issuer
  region            = var.aws_region

  depends_on = [module.eks_addons, module.eks_nodegroup, module.bastion, module.eks_access_entry]
}