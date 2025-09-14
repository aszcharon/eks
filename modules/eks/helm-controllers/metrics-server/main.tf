# kube-system namespace already exists in EKS

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.metrics_server_version
  timeout    = 600
  wait       = true
  wait_for_jobs = true

  values = [
    yamlencode({
      args = [
        "--cert-dir=/tmp",
        "--secure-port=4443",
        "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
        "--kubelet-use-node-status-port",
        "--metric-resolution=15s"
      ]
      # EKS 1.32 호환성 설정
      resources = {
        requests = {
          cpu = "100m"
          memory = "200Mi"
        }
      }
    })
  ]

  depends_on = [var.cluster_endpoint]
}