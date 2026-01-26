locals {
  name_prefix = "${var.project}-${var.env}-${var.name_suffix}"

  common_tags = merge(
    {
      Project = var.project
      Env     = var.env
      Role    = var.name_suffix
    },
    var.tags
  )
}

############################
# IAM Role
############################
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  count              = var.create_instance_profile ? 1 : 0
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_instance_profile ? toset(var.additional_iam_policy_arns) : toset([])

  role       = aws_iam_role.instance_role[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "instance_profile" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${local.name_prefix}-instance-profile"
  role  = aws_iam_role.instance_role[0].name
  tags  = local.common_tags
}

############################
# EC2 Instance
############################
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids

  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address

  iam_instance_profile = var.create_instance_profile
    ? aws_iam_instance_profile.instance_profile[0].name
    : var.iam_instance_profile_name

  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  tags = merge(
    local.common_tags,
    { Name = "${local.name_prefix}-ec2" }
  )
}

############################
# EIP
############################
resource "aws_eip" "this" {
  count  = var.create_eip ? 1 : 0
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "${local.name_prefix}-eip" })
}

resource "aws_eip_association" "this" {
  count         = var.create_eip ? 1 : 0
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this[0].allocation_id
}
