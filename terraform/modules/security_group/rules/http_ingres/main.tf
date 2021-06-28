resource "aws_security_group_rule" "allow_all_egress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.source_cidr

  security_group_id = var.sg_id
}
