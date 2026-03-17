data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name
  role = aws_iam_role.this.name

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.additional_managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
