############################
# compute_single variables
# - 현재 기준: SSH(.pem)로 접속 (SSM 미사용)
# - Cloudflare → EC2 Public IP 직접 접근(A) 가정
# - EIP 기본 OFF (필요 시 ON)
############################

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "name_suffix" {
  type    = string
  default = "app"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

############################
# Access 방식
# - enable_ssm=false면 key_name 필수
############################
variable "enable_ssm" {
  type    = bool
  default = false
}

variable "key_name" {
  type    = string
  default = null

  validation {
    condition     = var.enable_ssm || (var.key_name != null && length(trimspace(var.key_name)) > 0)
    error_message = "Either enable_ssm must be true, or key_name must be non-empty."
  }
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

############################
# IAM Instance Profile
############################
variable "create_instance_profile" {
  type    = bool
  default = true
}

variable "iam_instance_profile_name" {
  type    = string
  default = null

  validation {
    condition     = var.create_instance_profile || (var.iam_instance_profile_name != null && length(trimspace(var.iam_instance_profile_name)) > 0)
    error_message = "Either create_instance_profile must be true, or iam_instance_profile_name must be non-empty."
  }
}

variable "additional_iam_policy_arns" {
  type    = list(string)
  default = []
}

############################
# EIP (기본 OFF)
###########################
variable "create_eip" {
  type    = bool
  default = false
}

variable "user_data" {
  type    = string
  default = null
}

variable "user_data_replace_on_change" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
