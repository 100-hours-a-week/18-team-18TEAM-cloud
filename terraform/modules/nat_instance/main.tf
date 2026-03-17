resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address
  source_dest_check           = var.source_dest_check

  tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Module    = "nat_instance"
    },
    var.instance_tags
  )
}

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(
    {
      Name      = "${var.name}-eip"
      ManagedBy = "terraform"
      Module    = "nat_instance"
    },
    var.eip_tags
  )
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}
