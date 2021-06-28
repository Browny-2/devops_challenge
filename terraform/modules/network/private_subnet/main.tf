resource "aws_subnet" "private" {
  count             = length(split(",", var.cidrs))
  cidr_block        = element(split(",", var.cidrs), count.index)
  vpc_id            = var.vpc_id
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table" "private_routing_table" {
  count  = length(split(",", var.cidrs))
  vpc_id = var.vpc_id
}

resource "aws_route" "private_routes" {
  count                  = length(split(",", var.cidrs))
  route_table_id         = aws_route_table.private_routing_table.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateways[count.index]
}

resource "aws_route_table_association" "route_association" {
  count          = length(split(",", var.cidrs))
  route_table_id = aws_route_table.private_routing_table.*.id[count.index]
  subnet_id      = aws_subnet.private.*.id[count.index]
}