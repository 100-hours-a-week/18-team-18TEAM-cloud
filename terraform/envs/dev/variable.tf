variable "allowed_ssh_ips" {
    description = "List of CIDR blocks allowed to SSH"
    type    = list(string)
    default = []
}

variable "vpc_id" {
  type = string
}