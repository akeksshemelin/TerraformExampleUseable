# Yandex Cloud Terraform VM Template (FINAL)

Готовый эталонный шаблон для быстрого поднятия ВМ в Yandex Cloud.
Минимальные действия: скопируй `terraform.tfvars.example` → `terraform.tfvars`, укажи `cloud_id`, `folder_id`, путь к SA key JSON и SSH public key — и запускай.

## Что создаёт
- VPC, Subnet, Security Group (порты настраиваются)
- 1..N ВМ (масштабируется через map `vms`)
- Публичный IP: none | ephemeral | static (настраивается)
- SSH-доступ по ключу (cloud-init, без пароля)

---

## 1) Подготовка SSH-ключа (если ещё нет)

```bash
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# публичный ключ: ~/.ssh/id_ed25519.pub
```

## 2) Создание Service Account и key JSON (рекомендуемый способ аутентификации)

```bash
# 2.1 создать сервисный аккаунт
yc iam service-account create --name tf-admin --description "Terraform SA"

# 2.2 сохранить его ID в переменную
SA_ID=$(yc iam service-account get tf-admin --format json | jq -r .id)

# 2.3 дать роль в папке (замени FOLDER_ID на свой или возьми из yc config get folder-id)
FOLDER_ID=$(yc config get folder-id)
yc resource-manager folder add-access-binding --id "$FOLDER_ID"   --role editor --service-account-id "$SA_ID"

# 2.4 выпустить JSON ключ
mkdir -p ~/.config/yandex-cloud
yc iam key create --service-account-id "$SA_ID"   --output ~/.config/yandex-cloud/sa-key.json

# проверь, что файл существует:
ls -l ~/.config/yandex-cloud/sa-key.json
```

> Важно: в `terraform.tfvars` указывай **абсолютный путь** к файлу JSON (без `~`).

## 3) Быстрый запуск

```bash
cp terraform.tfvars.example terraform.tfvars
# отредактируй terraform.tfvars: yc_cloud_id, yc_folder_id, пути, vms и порты
terraform init
terraform apply -auto-approve
```

Подключение по SSH (если есть публичный IP):
```bash
ssh ubuntu@<PUBLIC_IP>
```

## 4) Удаление ресурсов

```bash
terraform destroy -auto-approve
```

---

## Полезные заметки

- Путь к SSH public key указывай на *.pub и абсолютный, например `/home/vagrant/.ssh/id_ed25519.pub`.
- Если нужен статический IP: для конкретной ВМ в `vms` укажи `public_ip_type = "static"`.
- Порты на вход задаются в `ingress_tcp_ports` (SSH 22 добавляется автоматически).
- Шаблон не дублирует провайдер в модуле, всё тянется из корня.
