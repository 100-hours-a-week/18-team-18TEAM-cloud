terraform {
  backend "s3" {
    bucket = "bizkit-build"

    key = "terraform/dev/terraform.tfstate"

    region = "ap-northeast-2"

    encrypt = true
  }
}
