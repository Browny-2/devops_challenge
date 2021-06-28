output "subnets" {
  value = aws_subnet.private.*.id
}