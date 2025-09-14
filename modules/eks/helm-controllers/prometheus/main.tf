resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  version    = "55.5.0"

  values = [
    yamlencode({
      prometheus = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
      }
      grafana = {
        enabled = false
      }
      alertmanager = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.prometheus]
}