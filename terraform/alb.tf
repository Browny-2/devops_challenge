// Security Group Creation
module "alb_security_group" {
  source      = "./modules/security_group"
  vpc_id      = module.base_network.vpc_id
  description = "SG for incoming ALB Traffic"
  env_name    = "utrust-alb"
}

module "allow_egress" {
  source = "./modules/security_group/rules/egress_all"
  sg_id  = module.alb_security_group.sg_id
}

module "http_ingres" {
  source = "./modules/security_group/rules/http_ingres"
  sg_id  = module.alb_security_group.sg_id
}

// Create ALB
module "ecs_application_load_balancer" {
  source          = "./modules/alb"
  public_subnets  = module.base_network.public_subnets
  env_name        = "utrust"
  security_groups = [module.alb_security_group.sg_id]
  lb = {
    internal = false
    target_group = {
      port     = 80
      protocol = "HTTP"
    }
  }
  vpc_id = module.base_network.vpc_id
}