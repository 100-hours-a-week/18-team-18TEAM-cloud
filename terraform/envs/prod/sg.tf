module "ssh" {
    source = "../../modules/sg"

    name        = "bizkit-prod-ssh-sg"
    description = "ssh for developers"

    vpc_id = data.terraform_remote_state.network.outputs.vpc_id

    ingress_rules = [
        {
        description = "allow ssh from specific ip"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.allowed_ssh_ips
        },
    ]

    tags = {
        Project = "bizkit"
        Env     = "prod"
        Tier    = "edge"
    }
}


module "webserver" {
    source = "../../modules/sg"

    name        = "bizkit-prod-webserver-sg"
    description = "allow http/https request from anywhere"

    vpc_id = data.terraform_remote_state.network.outputs.vpc_id

    ingress_rules = [
        {
        description = "allow HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        },
        {
        description = "allow HTTPs from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    ]

    tags = {
        Project = "bizkit"
        Env     = "prod"
        Tier    = "edge"
    }
}