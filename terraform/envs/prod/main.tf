provider "aws" {
  region  = "ap-northeast-2"
  profile = "bizkit"
}

variable "env" {
  type    = string
  default = "prod"
}