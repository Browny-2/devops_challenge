output "nat_gateways" {
  value = aws_nat_gateway.nat.*.id
}

output "subnets" {
  value = aws_subnet.public.*.id
}