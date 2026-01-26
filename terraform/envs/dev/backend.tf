terraform {
  backend "s3" {
    profile        = "bizkit"
    bucket         = "bizkit-terraform-state"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "bizkit-terraform-lock"
    encrypt        = true
  }
}