resource "aws_security_group_rule" "allow_all_egress" {
  type                     = "ingress"
  from_port                = var.sg["from"]
  to_port                  = var.sg["to"]
  protocol                 = var.sg["protocol"]
  source_security_group_id = var.source_sg_id

  security_group_id = var.sg_id
}
