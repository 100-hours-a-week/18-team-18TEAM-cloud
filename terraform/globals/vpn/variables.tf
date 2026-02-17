variable "name" {
  type = string
}

variable "vpn_security_group_name" {
  type = string
}

variable "vpn_security_group_description" {
  type = string
}

variable "vpn_security_group_name_v2" {
  type = string
}

variable "vpn_security_group_description_v2" {
  type = string
}

variable "vpn_sg_migration_mode" {
  description = "VPN SG migration mode: legacy (old SG only), dual (old+new), new (new SG only)."
  type        = string
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "dual", "new"], var.vpn_sg_migration_mode)
    error_message = "vpn_sg_migration_mode must be one of: legacy, dual, new."
  }
}

variable "vpn_eip_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "vpn_cidr" {
  type = string
}

variable "allowed_udp_cidrs" {
  type = list(string)
}

variable "allowed_ssh_cidrs" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "server_port" {
  type    = number
  default = 51820
}

variable "server_url" {
  type = string
}

variable "internal_subnet" {
  type = string
}

variable "allowed_ips" {
  type = string
}

variable "peer_dns" {
  type = string
}

variable "peers" {
  type = number
}

variable "prevent_destroy" {
  type    = bool
  default = true
}

variable "user_data_overwrite_ok" {
  type    = bool
  default = false
}

variable "source_dest_check" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
