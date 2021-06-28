output "rds_password" {
  value     = random_password.password.result
  sensitive = true
}

output "rds_address" {
  value = aws_db_instance.rds.address
}