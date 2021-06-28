output "app_url" {
  value       = aws_lb.alb.dns_name
  description = "The public ALB DNS"
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}