resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  version    = var.grafana_version

  values = [
    yamlencode({
      adminPassword = var.grafana_admin_password
      persistence = {
        enabled          = true
        storageClassName = "gp2"
        size             = "10Gi"
      }
      service = {
        type = "LoadBalancer"
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name   = "Prometheus"
              type   = "prometheus"
              url    = "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"
              access = "proxy"
              isDefault = true
            }
          ]
        }
      }
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }
          ]
        }
      }
      dashboards = {
        default = {
          kubernetes-cluster-monitoring = {
            gnetId     = 7249
            revision   = 1
            datasource = "Prometheus"
          }
          kubernetes-pod-monitoring = {
            gnetId     = 6417
            revision   = 1
            datasource = "Prometheus"
          }
        }
      }
    })
  ]

  depends_on = [var.prometheus_endpoint]
}