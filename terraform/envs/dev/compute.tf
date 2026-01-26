data "aws_instance" "existing" {
  instance_id = var.existing_instance_id
}

module "compute_single" {
  source = "../../modules/compute_single"

  project     = var.project
  env         = var.env
  name_suffix = "app"

  subnet_id              = data.aws_instance.existing.subnet_id
  security_group_ids     = data.aws_instance.existing.vpc_security_group_ids
  ami_id                 = data.aws_instance.existing.ami
  instance_type          = data.aws_instance.existing.instance_type
  key_name               = data.aws_instance.existing.key_name
  associate_public_ip_address = true

  create_instance_profile     = false
  iam_instance_profile_name   = data.aws_instance.existing.iam_instance_profile

  enable_ssm = false

  additional_iam_policy_arns = []
  create_eip = false

  tags = merge(var.tags, {
    Tier = "single-ec2"
  })
}

