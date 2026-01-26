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

