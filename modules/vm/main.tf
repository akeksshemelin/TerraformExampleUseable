locals {
  ssh_pubkey = trim(file(var.ssh_public_key_path))
  want_nat   = var.public_ip_type != "none"
}

# Опциональный статический адрес
resource "yandex_vpc_address" "static" {
  count = var.public_ip_type == "static" ? 1 : 0
  name  = "${var.name}-addr"
  external_ipv4_address {}
}

resource "yandex_compute_instance" "this" {
  name        = var.name
  platform_id = var.platform_id
  zone        = var.zone

  resources {
    cores  = var.cores
    memory = var.memory_gb
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size_gb
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = local.want_nat

    # если хотим статический — подставим адрес
    dynamic "nat_ip_address" {
      for_each = var.public_ip_type == "static" ? [1] : []
      content {
        address = yandex_vpc_address.static[0].external_ipv4_address[0].address
      }
    }

    security_group_ids = var.sg_ids
  }

  metadata = {
    ssh-keys  = "${var.ssh_username}:${local.ssh_pubkey}"
    user-data = <<-CLOUD
      #cloud-config
      disable_root: true
      ssh_pwauth: false
      users:
        - name: ${var.ssh_username}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
      CLOUD
  }
}
