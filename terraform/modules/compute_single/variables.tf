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
    condition     = var.enable_ssm || (var.key_name != null && length(trim(var.key_name)) > 0)
    error_message = "enable_ssm=false(SSH 사용)인 경우 key_name은 필수입니다."
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
    condition     = var.create_instance_profile || (var.iam_instance_profile_name != null && length(trim(var.iam_instance_profile_name)) > 0)
    error_message = "create_instance_profile=false이면 iam_instance_profile_name을 반드시 지정해야 합니다."
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
