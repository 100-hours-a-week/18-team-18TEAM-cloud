resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "bizkit-igw"
    Project   = "bizkit"
    ManagedBy = "terraform"
    Module    = "network"
  }
}