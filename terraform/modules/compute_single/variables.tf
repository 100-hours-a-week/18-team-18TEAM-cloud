variable "project" {
  description = "Application or service name used in naming and tags."
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
}

variable "name_suffix" {
  description = "Role name used in resource naming (e.g. app, api, worker)."
  type        = string
  default     = "app"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be placed."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the EC2 instance."
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro)."
  type        = string
}
variable "enable_ssm" {
  description = "If true, allow operation without key pair by using SSM access."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2 key pair name. Required when enable_ssm is false."
  type        = string
  default     = null

  validation {
    condition     = var.enable_ssm || (var.key_name != null && length(trimspace(var.key_name)) > 0)
    error_message = "Either enable_ssm must be true, or key_name must be non-empty."
  }
}

variable "associate_public_ip_address" {
  description = "Whether to auto-assign a public IPv4 address."
  type        = bool
  default     = true
}
variable "create_instance_profile" {
  description = "Create IAM role/profile in this module."
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Existing IAM instance profile name to attach when create_instance_profile is false."
  type        = string
  default     = null
}

variable "additional_iam_policy_arns" {
  description = "Additional IAM policy ARNs to attach when creating role/profile."
  type        = list(string)
  default     = []
}
variable "create_eip" {
  description = "Whether to create and associate an Elastic IP."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional user_data script for EC2 instance."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Recreate instance when user_data changes."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to merge into all resources."
  type        = map(string)
  default     = {}
}
