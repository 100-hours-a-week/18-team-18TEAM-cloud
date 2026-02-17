data "terraform_remote_state" "nat" {
  backend = "s3"

  config = {
    bucket  = "bizkit-terraform-state"
    key     = "globals/nat/terraform.tfstate"
    region  = "ap-northeast-2"
    profile = "bizkit"
  }
}
