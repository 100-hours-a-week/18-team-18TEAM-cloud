resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name      = "bizkit-dev-public-rt"
    Project   = "bizkit"
    Env       = "dev"
    Tier      = "public"
    ManagedBy = "terraform"
    Module    = "network"
  }
}

resource "aws_route_table_association" "dev_public_1" {
  subnet_id      = aws_subnet.dev_public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "bizkit-dev-private-rt"
    Project   = "bizkit"
    Env       = "dev"
    Tier      = "private"
    ManagedBy = "terraform"
    Module    = "network"
  }
}

resource "aws_route_table_association" "dev_private_1" {
  subnet_id      = aws_subnet.dev_private_1.id
  route_table_id = aws_route_table.private.id
}