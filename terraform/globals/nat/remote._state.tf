data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    profile = "bizkit"
    bucket  = "bizkit-terraform-state"
    key     = "globals/network/terraform.tfstate"
    region  = "ap-northeast-2"
  }
}
