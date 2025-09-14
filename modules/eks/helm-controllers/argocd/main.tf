resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.7.11"
  timeout    = 900
  wait       = true
  wait_for_jobs = true
  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
        extraArgs = [
          "--insecure"
        ]
      }
      configs = {
        params = {
          "server.insecure" = true
        }
      }
      # EKS 1.32 호환성을 위한 설정
      controller = {
        resources = {
          requests = {
            cpu = "100m"
            memory = "128Mi"
          }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}