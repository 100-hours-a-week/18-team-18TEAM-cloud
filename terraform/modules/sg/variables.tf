variable "name" {
  description = "security group name"
  type        = string
}

variable "description" {
  description = "security group description"
  type        = string
}

variable "vpc_id" {
  description = "vpc id that sg will be created"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    description      = optional(string)
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string), [])
    ipv6_cidr_blocks = optional(list(string), [])
    security_groups  = optional(list(string), [])
  }))
  # 기본값: 모든 곳으로 아웃바운드 허용
  default = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      security_groups  = []
    }
  ]
}

variable "tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}
}