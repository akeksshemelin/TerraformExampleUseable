# Yandex Cloud Terraform VM Template (scalable)

Фичи:
- Аутентификация: OAuth токен **или** Service Account key JSON
- VPC, Subnet, Security Group (входящие порты настраиваются)
- Масштабирование: любое количество ВМ через map `vms`
- Публичный IP: none | ephemeral | static
- SSH по ключу, cloud-init (без пароля)

## Быстрый старт
1) `cp terraform.tfvars.example terraform.tfvars` и заполни переменные.
2) `terraform init && terraform apply -auto-approve`
3) `ssh <ssh_username>@<vm_public_ip>` (если публичный IP включён)

Смотри `variables.tf` для параметров.
