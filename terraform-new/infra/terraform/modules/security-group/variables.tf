variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group is created."
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules for the security group."
  type = list(object({
    description      = string
    protocol         = string
    from_port        = number
    to_port          = number
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = []
}

variable "egress_rules" {
  description = "Egress rules for the security group."
  type = list(object({
    description      = string
    protocol         = string
    from_port        = number
    to_port          = number
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
    self             = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to the security group."
  type        = map(string)
  default     = {}
}
