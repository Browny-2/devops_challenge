resource "aws_db_subnet_group" "subnet_group" {
  name       = var.env_name
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env_name}-subnet-group"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "aws_db_instance" "rds" {
  allocated_storage      = var.storage_size
  engine                 = var.engine
  engine_version         = var.rds_version
  instance_class         = var.instance_size
  name                   = var.db_name
  identifier             = "${var.env_name}-db"
  username               = var.user
  password               = random_password.password.result
  parameter_group_name   = var.param_group
  skip_final_snapshot    = true
  vpc_security_group_ids = var.security_groups
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name

  tags = {
    Name = "${var.env_name}-postgres-db"
  }
}