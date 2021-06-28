resource "aws_lb" "alb" {
  name               = "${var.env_name}-alb"
  internal           = var.lb["internal"]
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.public_subnets

  enable_deletion_protection = false // This would be set to true in live systems

  // Logs would be enabled in live systems
  //  access_logs {
  //    bucket  = aws_s3_bucket.lb_logs.bucket
  //    prefix  = "test-lb"
  //    enabled = true
  //  }

  tags = {
    Environment = "${var.env_name}-task"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.env_name}-alb-tg"
  port        = var.lb.target_group["port"]
  protocol    = var.lb.target_group["protocol"]
  vpc_id      = var.vpc_id
  target_type = "ip"

  depends_on = [aws_lb.alb]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}