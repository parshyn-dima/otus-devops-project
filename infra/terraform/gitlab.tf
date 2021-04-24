resource "yandex_compute_instance" "gitlab" {
  name     = "gitlab"
  hostname = "gitlab"

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 8
    memory = 8
  }

  boot_disk {
    initialize_params {
      #image_id = data.yandex_compute_image.ubuntu_image.id
      image_id = var.gitlab_image_id
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = true
  }
}

# resource "null_resource" "deploy_gitlab" {
#   provisioner "local-exec" {
#   working_dir = "../ansible/"
#   command = "sleep 60 && ansible-playbook install_gitlab.yml"
#   }

#    triggers = {
#      addrs = join(",", local.ips_gitlab),
#    }

#   depends_on = [local_file.generate_inventory,yandex_compute_instance.master]
# }
