resource "aws_subnet" "dev_public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"

  tags = {
    Name      = "bizkit-dev-public-1"
    Project   = "bizkit"
    Env       = "dev"
    Tier      = "public"
    ManagedBy = "terraform"
    Module    = "network"
  }
}

resource "aws_subnet" "dev_private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name      = "bizkit-dev-private-1"
    Project   = "bizkit"
    Env       = "dev"
    Tier      = "private"
    ManagedBy = "terraform"
    Module    = "network"
  }
}