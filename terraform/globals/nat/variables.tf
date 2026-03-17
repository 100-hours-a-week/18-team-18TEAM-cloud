variable "project" {
  description = "Project name used for tags."
  type        = string
}

variable "nat_sg_migration_mode" {
  description = "NAT security group migration mode: legacy (old SG only), dual (old+new), new (new SG only)."
  type        = string
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "dual", "new"], var.nat_sg_migration_mode)
    error_message = "nat_sg_migration_mode must be one of: legacy, dual, new."
  }
}

variable "legacy_nat_security_group_ids" {
  description = "Legacy NAT SG IDs keyed by nat_instances key (e.g. dev_a, prod_a)."
  type        = map(string)
  default     = {}
}

variable "vpn_sg_id" {
  description = "VPN security group ID allowed to SSH to NAT instances."
  type        = string
}

variable "nat_instances" {
  description = "NAT instances keyed by logical key (e.g. dev_a, prod_a)."
  type = map(object({
    name                        = string
    ami_id                      = string
    instance_type               = string
    subnet_id                   = string
    security_group_ids          = list(string)
    key_name                    = string
    iam_instance_profile_name   = optional(string, null)
    associate_public_ip_address = optional(bool, true)
    source_dest_check           = optional(bool, false)
    instance_tags               = optional(map(string), {})
    eip_tags                    = optional(map(string), {})
  }))
}
