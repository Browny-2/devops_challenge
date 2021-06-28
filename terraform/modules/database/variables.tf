variable "storage_size" { default = "10" }
variable "engine" { default = "postgres" }
variable "rds_version" { default = "12.5" }
variable "instance_size" { default = "db.t2.micro" }
variable "env_name" {}
variable "db_name" {}
variable "user" {}
variable "param_group" { default = "default.postgres12" }
variable "security_groups" { default = "" }
variable "subnets" {}