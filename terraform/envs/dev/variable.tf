variable "allowed_ssh_ips" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = []
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type = string
}

variable "name_suffix" {
  description = "Role suffix used in compute naming."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for imported dev compute instance."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to imported dev compute instance."
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID of imported dev compute instance."
  type        = string
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate public IPv4 on the dev compute instance."
  type        = bool
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name attached to imported dev compute instance."
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
  description = "VPN security group ID allowed to access dev services."
  type        = string
}

variable "dev_nat_sg_id" {
  description = "Dev NAT security group ID used in SG-to-SG egress rule."
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

variable "enable_metrics_instance" {
  description = "Whether to manage the dev metrics instance in this stack."
  type        = bool
  default     = false
}

variable "metrics_name_suffix" {
  description = "Role suffix used in metrics compute naming."
  type        = string
  default     = "metrics"
}

variable "metrics_subnet_id" {
  description = "Subnet ID for the dev metrics instance."
  type        = string
  default     = ""
}

variable "metrics_security_group_ids" {
  description = "Security group IDs attached to the dev metrics instance."
  type        = list(string)
  default     = []
}

variable "metrics_ami_id" {
  description = "AMI ID of the dev metrics instance."
  type        = string
  default     = ""
}

variable "metrics_key_name" {
  description = "Key pair name for the dev metrics instance."
  type        = string
  default     = null
}

variable "metrics_instance_type" {
  description = "Instance type of the dev metrics instance."
  type        = string
  default     = ""
}

variable "metrics_associate_public_ip_address" {
  description = "Whether to associate public IPv4 on the dev metrics instance."
  type        = bool
  default     = false
}

variable "metrics_iam_instance_profile_name" {
  description = "IAM instance profile name attached to the dev metrics instance. Null means no profile."
  type        = string
  default     = null
}
