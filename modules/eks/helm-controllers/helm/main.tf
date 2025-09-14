resource "null_resource" "install_helm" {
  provisioner "remote-exec" {
    inline = [
      "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",
      "helm version"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = var.bastion_host
    }
  }
}

resource "null_resource" "verify_helm" {
  provisioner "remote-exec" {
    inline = [
      "helm version --short"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.private_key
      host        = var.bastion_host
    }
  }

  depends_on = [null_resource.install_helm]
}