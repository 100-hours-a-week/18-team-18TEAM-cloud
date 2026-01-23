module "ssh" {
    source = "../../modules/sg"

    name        = "bizkit-dev-ssh-sg"
    description = "allow ssh tunneling"


    #remote 적용 이후
    # vpc_id = data.terraform_remote_state.network.outputs.vpc_id
    vpc_id = var.vpc_id

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
        Env     = "dev"
        Tier    = "edge"
    }
}


module "webserver" {
    source = "../../modules/sg"

    name        = "bizkit-dev-webserver-sg"
    description = "webserver-sg"

    vpc_id = var.vpc_id

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
        Env     = "dev"
        Tier    = "edge"
    }
}