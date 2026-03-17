variable "project" {
  description = "Project name used in resource naming and tags."
  type        = string
}

variable "env" {
  description = "Environment name for shared monitoring."
  type        = string
  default     = "shared"
}

variable "name_suffix" {
  description = "Role suffix used in compute naming."
  type        = string
  default     = "monitoring"
}

variable "subnet_id" {
  description = "Subnet ID for the shared monitoring instance."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the shared ops security group is created."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the monitoring instance."
  type        = list(string)
}

variable "ops_sg_migration_mode" {
  description = "Shared ops SG migration mode: legacy (old SG only), dual (old+new), new (new SG only)."
  type        = string
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "dual", "new"], var.ops_sg_migration_mode)
    error_message = "ops_sg_migration_mode must be one of: legacy, dual, new."
  }
}

variable "ops_legacy_sg_ids" {
  description = "Legacy shared ops SG IDs to replace."
  type        = list(string)
  default     = []
}

variable "vpn_sg_id" {
  description = "VPN security group ID allowed to SSH into shared monitoring."
  type        = string
}

variable "ami_id" {
  description = "AMI ID of the monitoring instance."
  type        = string
}

variable "instance_type" {
  description = "Instance type of the monitoring instance."
  type        = string
}

variable "key_name" {
  description = "Key pair name for the monitoring instance."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IPv4 address."
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name attached to the monitoring instance. Null means none."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags merged to monitoring resources."
  type        = map(string)
  default     = {}
}
