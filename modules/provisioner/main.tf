resource "null_resource" "install_docker" {
  connection {
    agent       = false
    timeout     = "500s"
    host        = var.instance_ip
    user        = var.user
    private_key = file(var.privatekeypath)
  }

  provisioner "file" {
    source      = "${path.module}/startup.sh"
    destination = "/tmp/startup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/startup.sh",
      "bash /tmp/startup.sh '${var.user}'"
    ]
  }
}

resource "null_resource" "clone_repository" {
  depends_on = [null_resource.install_docker]

  connection {
    agent       = false
    timeout     = "500s"
    host        = var.instance_ip
    user        = var.user
    private_key = file(var.privatekeypath)
  }

  provisioner "remote-exec" {
    inline = [
      "if [ -d /tmp/amnezia-wg-easy ]; then rm -rf /tmp/amnezia-wg-easy; fi",
      "git clone https://github.com/w0rng/amnezia-wg-easy /tmp/amnezia-wg-easy"
    ]
  }
}

resource "null_resource" "build_amnezia_image" {
  depends_on = [null_resource.clone_repository]

  connection {
    agent       = false
    timeout     = "500s"
    host        = var.instance_ip
    user        = var.user
    private_key = file(var.privatekeypath)
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/amnezia-wg-easy",
      "docker build -t amnezia-wg-easy ."
    ]
  }
}

data "local_file" "wg0_conf" {
  count    = var.enable_wg_configs ? 1 : 0
  filename = "${path.module}/wg_backup/wg0.conf"
}

data "local_file" "wg0_json" {
  count    = var.enable_wg_configs ? 1 : 0
  filename = "${path.module}/wg_backup/wg0.json"
}

resource "null_resource" "copy_wireguard_configs" {
  count = var.enable_wg_configs ? 1 : 0

  connection {
    agent       = false
    timeout     = "500s"
    host        = var.instance_ip
    user        = var.user
    private_key = file(var.privatekeypath)
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${data.local_file.wg0_conf[0].content}' | sudo tee /home/${var.user}/.amnezia-wg-easy/wg0.conf > /dev/null",
      "echo '${data.local_file.wg0_json[0].content}' | sudo tee /home/${var.user}/.amnezia-wg-easy/wg0.json > /dev/null",
      "sudo chown root:root /home/${var.user}/.amnezia-wg-easy/wg0.conf",
      "sudo chown root:root /home/${var.user}/.amnezia-wg-easy/wg0.json"
    ]
  }
}

resource "null_resource" "run_amnezia_docker_container" {
  depends_on = [null_resource.build_amnezia_image]

  connection {
    agent       = false
    timeout     = "500s"
    host        = var.instance_ip
    user        = var.user
    private_key = file(var.privatekeypath)
  }

  provisioner "file" {
    source      = "${path.module}/amnezia-wg-easy.sh"
    destination = "/home/${var.user}/amnezia-wg-easy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.user}/amnezia-wg-easy.sh",
      "bash /home/${var.user}/amnezia-wg-easy.sh ${var.wg_host} '${var.wg_password}'"
    ]
  }
}
