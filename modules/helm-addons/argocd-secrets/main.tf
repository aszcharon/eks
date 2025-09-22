# ArgoCD 서비스 정보 가져오기
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
}

# ArgoCD 초기 비밀번호 가져오기
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

# Bastion에 ArgoCD 정보 저장
resource "null_resource" "save_argocd_secrets" {
  provisioner "remote-exec" {
    inline = [
      "echo 'ArgoCD Access Information' > /home/ec2-user/argo_secrets",
      "echo '=========================' >> /home/ec2-user/argo_secrets",
      "echo 'URL: http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}' >> /home/ec2-user/argo_secrets",
      "echo 'Username: admin' >> /home/ec2-user/argo_secrets",
      "echo 'Password: ${base64decode(data.kubernetes_secret.argocd_initial_admin_secret.data.password)}' >> /home/ec2-user/argo_secrets",
      "echo '' >> /home/ec2-user/argo_secrets",
      "echo 'CLI Login:' >> /home/ec2-user/argo_secrets",
      "echo 'argocd login ${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname} --username admin --password ${base64decode(data.kubernetes_secret.argocd_initial_admin_secret.data.password)} --insecure' >> /home/ec2-user/argo_secrets",
      "chmod 600 /home/ec2-user/argo_secrets"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = var.bastion_host
    }
  }
}