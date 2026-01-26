variable "allowed_ssh_ips" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  type = string
}

##########################
# Compute Variables
##########################
variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project" {
  type = string
}

variable "env" {
  type    = string
  default = "dev"
}

variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "existing_instance_id" {
  description = "이미 존재하는 dev EC2 인스턴스 ID(import 대상)"
  type        = string
}

