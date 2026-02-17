variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type    = string
  default = null
}

variable "name" {
  type = string
}

variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "tier" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "routes" {
  type = list(object({
    cidr_block  = string
    target_type = string
    target_id   = optional(string)
  }))
  default = []
}

variable "associate_subnet_ids" {
  type    = list(string)
  default = []
}
