module "ecs_security_group" {
  source      = "./modules/security_group"
  vpc_id      = module.base_network.vpc_id
  description = "SG for ECS Traffic"
  env_name    = "utrust-ecs"
}

module "ecs_allow_egress" {
  source = "./modules/security_group/rules/egress_all"
  sg_id  = module.ecs_security_group.sg_id
}

module "ecs_http_ingres" {
  source = "./modules/security_group/rules/sg_to_sg"
  sg_id  = module.ecs_security_group.sg_id
  sg = {
    from     = "80"
    to       = "80"
    protocol = "tcp"
  }
  source_sg_id = module.alb_security_group.sg_id
}

// create ECR repo and lifecycle
module "container_repository" {
  source         = "./modules/ecr"
  repo_name      = "utrust/docker"
  tag_mutability = "MUTABLE"
}

// ECS cluster, task definition, service
module "ecs_cluster" {
  source = "./modules/ecs"
  ecs = {
    cluster_name    = "utrust"
    container_name  = "users_api"
    service_name    = "users_api"
    container_image = "${module.container_repository.ecr_url}"
    container_port  = "80"
    ports           = [80]
    repo_name      = "utrust/docker"
  }
  subnets          = module.base_network.private_subnets
  target_group_arn = module.ecs_application_load_balancer.target_group_arn
  depends_on       = [module.rds_instance.rds_address]
  security_groups  = [module.ecs_security_group.sg_id]
}