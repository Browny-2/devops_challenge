resource "aws_subnet" "public" {
  count                   = length(split(",", var.cidrs))
  cidr_block              = element(split(",", var.cidrs), count.index)
  vpc_id                  = var.vpc_id
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
}

resource "aws_route_table" "public_routing_table" {
  vpc_id = var.vpc_id
}

resource "aws_route" "public_routes" {
  route_table_id         = aws_route_table.public_routing_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "route_association" {
  count          = length(split(",", var.cidrs))
  route_table_id = aws_route_table.public_routing_table.id
  subnet_id      = aws_subnet.public.*.id[count.index]
}

resource "aws_eip" "nat_eip" {
  vpc   = true
  count = length(split(",", var.cidrs))
}

resource "aws_nat_gateway" "nat" {
  count         = length(split(",", var.cidrs))
  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id     = aws_subnet.public.*.id[count.index]
}