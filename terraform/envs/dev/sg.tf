module "ssh" {
  source = "../../modules/sg"

  name        = "bizkit-dev-ssh-sg"
  description = "ssh for developers"

    vpc_id = data.terraform_remote_state.network.outputs.vpc_id


  ingress_rules = [
    {
      description = "allow ssh from specific ip"
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_ips
    },
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
  }
}


module "webserver" {
  source = "../../modules/sg"

  name        = "bizkit-dev-webserver-sg"
  description = "allow http/https request from anywhere"
  
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id


  ingress_rules = [
    {
      description = "allow HTTP from anywhere"
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    },
    {
      description = "allow HTTPS from anywhere"
      from_port   = var.https_port
      to_port     = var.https_port
      protocol    = "tcp"
      cidr_blocks = [var.public_cidr]
    }
  ]

  tags = {
    Project = var.project
    Env     = var.env
    Tier    = "edge"
  }
}