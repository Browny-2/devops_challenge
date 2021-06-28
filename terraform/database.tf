// Security Group Creation
module "rds_security_group" {
  source      = "./modules/security_group"
  vpc_id      = module.base_network.vpc_id
  description = "SG for incoming RDS Traffic"
  env_name    = "utrust"
}

module "http_alb_to_rds" {
  source = "./modules/security_group/rules/sg_to_sg"
  sg_id  = module.rds_security_group.sg_id
  sg = {
    from     = "5432"
    to       = "5432"
    protocol = "tcp"
  }
  source_sg_id = module.ecs_security_group.sg_id
}

module "rds_instance" {
  source          = "./modules/database"
  env_name        = "utrust"
  db_name         = "api"
  user            = "postgres"
  subnets         = module.base_network.private_subnets
  security_groups = [module.rds_security_group.sg_id]
}