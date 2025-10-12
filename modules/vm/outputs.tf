output "internal_ip" {
  value = yandex_compute_instance.this.network_interface[0].ip_address
}

output "public_ip" {
  value = try(yandex_compute_instance.this.network_interface[0].nat_ip_address, null)
}

output "fqdn" {
  value = yandex_compute_instance.this.fqdn
}
