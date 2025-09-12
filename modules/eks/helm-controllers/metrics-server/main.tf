resource "kubernetes_namespace" "metrics_server" {
  metadata {
    name = "kube-system"
  }
  
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = var.metrics_server_version

  set {
    name  = "args"
    value = "{--cert-dir=/tmp,--secure-port=4443,--kubelet-preferred-address-types=InternalIP\\,ExternalIP\\,Hostname,--kubelet-use-node-status-port,--metric-resolution=15s}"
  }

  depends_on = [var.cluster_endpoint]
}