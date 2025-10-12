output "network_id" { value = yandex_vpc_network.this.id }
output "subnet_id"  { value = yandex_vpc_subnet.this.id }

output "vm_info" {
  description = "Карточки по ВМ: внутренний/внешний IP, FQDN"
  value = {
    for k, m in module.vm :
    k => {
      internal_ip = m.internal_ip
      public_ip   = m.public_ip
      fqdn        = m.fqdn
    }
  }
}
