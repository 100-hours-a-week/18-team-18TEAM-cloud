variable "allowed_ssh_ips" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = []
}

variable "env" {
  type    = string
  default = "prod"
}

variable "project" {
  type = string
}

variable "name_suffix" {
  description = "Role suffix used in compute naming."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for imported prod compute instance."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to imported prod compute instance."
  type        = list(string)
}

variable "primary_legacy_sg_ids" {
  description = "Legacy SG IDs to replace during prod SG migration (ssh/webserver/monitor)."
  type        = list(string)
  default     = []
}

variable "ami_id" {
  description = "AMI ID of imported prod compute instance."
  type        = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IPv4 on the prod compute instance."
  type        = bool
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name attached to imported prod compute instance."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_cidr" {
  type = string
}

variable "ssh_port" {
  type = number
}

variable "http_port" {
  type = number
}

variable "https_port" {
  type = number
}

variable "vpn_sg_id" {
  description = "VPN security group ID allowed to access prod services."
  type        = string
}

variable "monitoring_sg_id" {
  description = "Monitoring system SG ID allowed to scrape application metrics."
  type        = string
}

variable "sg_migration_mode" {
  description = "Security group migration mode: legacy (old SG only), dual (old+new), new (new SG only)."
  type        = string
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "dual", "new"], var.sg_migration_mode)
    error_message = "sg_migration_mode must be one of: legacy, dual, new."
  }
}

variable "remove_legacy_sg" {
  description = "When true, stop managing and destroy legacy SGs after full migration to new SGs."
  type        = bool
  default     = false

  validation {
    condition     = !var.remove_legacy_sg || var.sg_migration_mode == "new"
    error_message = "remove_legacy_sg can be true only when sg_migration_mode is new."
  }
}

variable "alb_sg_migration_mode" {
  description = "ALB SG migration mode: legacy (old SG only), dual (old+new), new (new SG only)."
  type        = string
  default     = "legacy"

  validation {
    condition     = contains(["legacy", "dual", "new"], var.alb_sg_migration_mode)
    error_message = "alb_sg_migration_mode must be one of: legacy, dual, new."
  }
}

variable "app_alb_legacy_sg_ids" {
  description = "Legacy application SG IDs that allow traffic from ALB."
  type        = list(string)
  default     = []
}

variable "alb_name" {
  description = "ALB name for prod environment."
  type        = string
}

variable "alb_internal" {
  description = "Whether prod ALB is internal."
  type        = bool
}

variable "alb_security_group_ids" {
  description = "Security group IDs attached to prod ALB."
  type        = list(string)
}

variable "alb_subnet_ids" {
  description = "Subnet IDs used by prod ALB."
  type        = list(string)
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener."
  type        = string
}

variable "alb_ssl_policy" {
  description = "SSL policy for HTTPS listener."
  type        = string
}
