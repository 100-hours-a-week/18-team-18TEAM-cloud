variable "project" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(object({
    name                    = string
    env                     = string
    tier                    = string
    availability_zone       = string
    cidr_block              = string
    map_public_ip_on_launch = bool
    tags                    = optional(map(string), {})
  }))
}

variable "route_tables" {
  type = map(object({
    name = string
    env  = string
    tier = string
    routes = optional(list(object({
      cidr_block  = string
      target_type = string
      target_id   = optional(string)
      nat_key     = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "route_table_associations" {
  type = map(object({
    route_table_key = string
    subnet_key      = string
  }))
  default = {}
}
