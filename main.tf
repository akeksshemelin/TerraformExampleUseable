terraform {
  required_version = ">= 1.5.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120"
    }
  }
}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.zone

  # Выбираем конкретный способ аутентификации
  token                    = var.auth_method == "oauth" ? var.yc_token : null
  service_account_key_file = var.auth_method == "sa"    ? var.service_account_key_file : null
}

# ----- Сеть -----
resource "yandex_vpc_network" "this" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.vpc_name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.subnet_cidr]
}

# ----- Security Group -----
resource "yandex_vpc_security_group" "this" {
  name       = "sg-main"
  network_id = yandex_vpc_network.this.id

  # Разрешаем исходящий трафик везде
  egress {
    protocol       = "ANY"
    description    = "Any egress"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH всегда
  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.ingress_cidrs
  }

  # Дополнительные TCP-порты из списка
  dynamic "ingress" {
    for_each = var.ingress_tcp_ports
    content {
      description    = "TCP port ${ingress.value}"
      protocol       = "TCP"
      port           = ingress.value
      v4_cidr_blocks = var.ingress_cidrs
    }
  }
}

# Образ по семейству
data "yandex_compute_image" "os_image" {
  family = var.image_family
}

# ----- Массовое создание ВМ -----
module "vm" {
  source   = "./modules/vm"
  for_each = var.vms

  name        = "vm-${each.key}"
  zone        = var.zone
  subnet_id   = yandex_vpc_subnet.this.id
  sg_ids      = [yandex_vpc_security_group.this.id]

  platform_id = var.platform_id
  cores       = coalesce(lookup(each.value, "cores", null), var.cores)
  memory_gb   = coalesce(lookup(each.value, "memory_gb", null), var.memory_gb)
  disk_size_gb= coalesce(lookup(each.value, "disk_size_gb", null), var.disk_size_gb)
  preemptible = coalesce(lookup(each.value, "preemptible", null), var.preemptible)

  image_id    = data.yandex_compute_image.os_image.id
  ssh_username= var.ssh_username
  ssh_public_key_path = var.ssh_public_key_path

  public_ip_type = coalesce(lookup(each.value, "public_ip_type", null), var.public_ip_type)
}
