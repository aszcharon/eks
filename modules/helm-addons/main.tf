module "helm" {
  source = "./helm"

  private_key  = var.private_key
  bastion_host = var.bastion_host
  cluster_name = var.cluster_name
}

module "aws_load_balancer_controller" {
  source = "./aws-load-balancer-controller"

  cluster_name      = var.cluster_name
  oidc_provider_arn = var.oidc_provider_arn
  oidc_issuer       = var.oidc_issuer
  region            = var.region
}

module "metrics_server" {
  source = "./metrics-server"

  cluster_endpoint = var.cluster_endpoint

  depends_on = [module.aws_load_balancer_controller]
}

module "argocd" {
  source = "./argocd"

  cluster_name = var.cluster_name

  depends_on = [module.aws_load_balancer_controller]
}

module "prometheus" {
  source = "./prometheus"

  cluster_name = var.cluster_name

  depends_on = [module.aws_load_balancer_controller]
}

module "grafana" {
  source = "./grafana"

  cluster_name = var.cluster_name

  depends_on = [module.aws_load_balancer_controller]
}

module "argocd_secrets" {
  source = "./argocd-secrets"

  private_key  = var.private_key
  bastion_host = var.bastion_host

  depends_on = [module.argocd, module.prometheus, module.grafana, module.aws_load_balancer_controller]
}