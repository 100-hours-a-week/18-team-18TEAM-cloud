variable "name" {
  description = "Load balancer name."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
  default     = true
}

variable "load_balancer_type" {
  description = "AWS load balancer type."
  type        = string
  default     = "network"
}

variable "subnet_ids" {
  description = "Subnets attached to the load balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for ALB. Ignored for NLB."
  type        = list(string)
  default     = []
}

variable "listener_port" {
  description = "Listener port."
  type        = number
}

variable "listener_protocol" {
  description = "Listener protocol."
  type        = string
}

variable "target_port" {
  description = "Target group port."
  type        = number
}

variable "target_group_protocol" {
  description = "Target group protocol."
  type        = string
}

variable "target_type" {
  description = "Target group type."
  type        = string
  default     = "instance"
}

variable "target_instance_ids" {
  description = "Target instance IDs."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for the target group."
  type        = string
}

variable "health_check_protocol" {
  description = "Health check protocol."
  type        = string
  default     = "TCP"
}

variable "health_check_path" {
  description = "Health check path for HTTP/HTTPS target groups."
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Health check port."
  type        = string
  default     = "traffic-port"
}

variable "tags" {
  description = "Tags applied to load balancer resources."
  type        = map(string)
  default     = {}
}
