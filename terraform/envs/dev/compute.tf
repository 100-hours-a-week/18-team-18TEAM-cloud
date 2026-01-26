############################################
# envs/dev/compute.tf
# 목표: 기존 EC2를 Terraform state로 "import"해서 관리
# - remote_state/network 의존 제거
# - AMI most_recent 제거(교체 방지)
############################################

# TODO: 기존 dev EC2 인스턴스 ID를 tfvars에 넣을 것
data "aws_instance" "existing" {
  instance_id = var.existing_instance_id
}

module "compute_single" {
  source = "../../modules/compute_single"

  project     = var.project
  env         = var.env
  name_suffix = "app" # 이름 태그/리소스 접두사에만 쓰임(인스턴스 내부 설정과 무관)

  subnet_id              = data.aws_instance.existing.subnet_id
  security_group_ids     = data.aws_instance.existing.vpc_security_group_ids
  ami_id                 = data.aws_instance.existing.ami
  instance_type          = data.aws_instance.existing.instance_type
  key_name               = data.aws_instance.existing.key_name
  associate_public_ip_address = true # (이미 퍼블릭IP 붙어있는 구조면 true 유지)

  create_instance_profile     = false
  iam_instance_profile_name   = data.aws_instance.existing.iam_instance_profile

  enable_ssm = false

  additional_iam_policy_arns = []
  create_eip = false

  tags = merge(var.tags, {
    Tier = "single-ec2"
  })
}

