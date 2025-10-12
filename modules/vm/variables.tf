variable "name"         { type = string }
variable "zone"         { type = string }
variable "subnet_id"    { type = string }
variable "sg_ids"       { type = list(string) }

variable "platform_id"  { type = string }
variable "cores"        { type = number }
variable "memory_gb"    { type = number }
variable "disk_size_gb" { type = number }
variable "preemptible"  { type = bool }

variable "image_id"     { type = string }
variable "ssh_username" { type = string }
variable "ssh_public_key_path" { type = string }

# none | ephemeral | static
variable "public_ip_type" {
  type    = string
  default = "ephemeral"
}
