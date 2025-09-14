resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.grafana.metadata[0].name
  version    = "7.0.19"

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
        }
      }
      adminPassword = "admin123!"
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name = "Prometheus"
              type = "prometheus"
              url = "http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090"
              access = "proxy"
              isDefault = true
            }
          ]
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.grafana]
}