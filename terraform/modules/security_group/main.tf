resource "aws_security_group" "sg" {
  name        = "${var.env_name}-security-group"
  description = var.description
  vpc_id      = var.vpc_id
}
