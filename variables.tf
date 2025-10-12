variable "auth_method" {
  description = "Способ аутентификации: oauth | sa"
  type        = string
  default     = "sa"
  validation {
    condition     = contains(["oauth", "sa"], var.auth_method)
    error_message = "auth_method must be 'oauth' or 'sa'."
  }
}

variable "yc_token" {
  description = "OAuth токен (если auth_method = oauth)"
  type        = string
  default     = null
  sensitive   = true
}

variable "service_account_key_file" {
  description = "Путь к service account key JSON (если auth_method = sa)"
  type        = string
  default     = "~/.config/yandex-cloud/sa-key.json"
}

variable "yc_cloud_id" { type = string }
variable "yc_folder_id" { type = string }

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "vpc_name" {
  type    = string
  default = "vpc-main"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "image_family" {
  description = "Семейство образов ОС"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

# --- Security Group ---
variable "ingress_cidrs" {
  description = "Список CIDR, откуда разрешён вход"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_tcp_ports" {
  description = "Список разрешённых TCP портов (SSH 22 добавляется всегда)"
  type        = list(number)
  default     = [80, 443]
}

# --- Профиль ВМ по умолчанию (применяется ко всем, если не переопределить в vms) ---
variable "platform_id" {
  type    = string
  default = "standard-v3"
}
variable "cores"       { type = number, default = 2 }
variable "memory_gb"   { type = number, default = 2 }
variable "disk_size_gb"{ type = number, default = 20 }
variable "preemptible" { type = bool,   default = false }

# Публичный IP: "none" | "ephemeral" | "static"
variable "public_ip_type" {
  type    = string
  default = "ephemeral"
  validation {
    condition     = contains(["none", "ephemeral", "static"], var.public_ip_type)
    error_message = "public_ip_type must be one of: none, ephemeral, static."
  }
}

# --- Масштабирование: карта ВМ ---
# Ключ карты — суффикс имени ВМ (будет vm-<key>)
variable "vms" {
  description = "Набор ВМ для развертывания"
  type = map(object({
    cores        = optional(number)
    memory_gb    = optional(number)
    disk_size_gb = optional(number)
    preemptible  = optional(bool)
    # на всякий случай позволим разный тип IP на ВМ
    public_ip_type = optional(string) # none|ephemeral|static
  }))
  default = {
    "app-1" = {}
  }
}
