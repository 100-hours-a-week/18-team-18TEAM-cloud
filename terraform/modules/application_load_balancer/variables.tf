variable "name" {
  description = "Application Load Balancer name."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "Load balancer type."
  type        = string
  default     = "application"
}

variable "ip_address_type" {
  description = "IP address type for the load balancer."
  type        = string
  default     = "ipv4"
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Security group IDs attached to the load balancer."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnet IDs used by the load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for target groups."
  type        = string
}

variable "target_groups" {
  description = "Target groups keyed by logical name."
  type = map(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = optional(string, "instance")
    deregistration_delay = optional(number)
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number)
      interval            = optional(number)
      matcher             = optional(string)
      path                = optional(string)
      port                = optional(string)
      protocol            = optional(string)
      timeout             = optional(number)
      unhealthy_threshold = optional(number)
    }))
  }))
  default = {}
}

variable "listeners" {
  description = "Listeners keyed by logical name."
  type = map(object({
    port            = number
    protocol        = string
    certificate_arn = optional(string)
    ssl_policy      = optional(string)
    default_action = object({
      type             = string
      target_group_key = optional(string)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
      redirect = optional(object({
        status_code = string
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
      }))
    })
  }))
  default = {}
}

variable "listener_rules" {
  description = "Optional listener rules keyed by logical name."
  type = map(object({
    listener_key = string
    priority     = number
    conditions = object({
      host_headers  = optional(list(string), [])
      path_patterns = optional(list(string), [])
    })
    action = object({
      type             = string
      target_group_key = optional(string)
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
      redirect = optional(object({
        status_code = string
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
      }))
    })
  }))
  default = {}
}

variable "target_group_attachments" {
  description = "Target group attachments keyed by logical name."
  type = map(object({
    target_group_key  = string
    target_id         = string
    port              = optional(number)
    availability_zone = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
