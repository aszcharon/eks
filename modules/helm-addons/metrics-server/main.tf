# Metrics Server - 클러스터 리소스 사용량 수집
# HPA, VPA 등 오토스케일링에 필수

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = "3.12.2"
  namespace        = "kube-system"
  timeout          = 300
  wait             = true
  atomic           = true
  create_namespace = false

  values = [
    yamlencode({
      args = [
        "--cert-dir=/tmp",
        "--secure-port=4443",
        "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
        "--kubelet-use-node-status-port",
        "--metric-resolution=15s"
      ]
      resources = {
        requests = {
          cpu = "100m"
          memory = "200Mi"
        }
        limits = {
          cpu = "200m"
          memory = "400Mi"
        }
      }
      replicas = 1
    })
  ]

  depends_on = [var.cluster_endpoint]
}