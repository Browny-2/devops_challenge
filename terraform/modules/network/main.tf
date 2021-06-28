# Base VPC Creation
module "vpc" {
  source = "./vpc"

  vpc_name = var.env_name
  cidr     = var.cidr
}

module "public_subnet" {
  source = "./public_subnet"
  vpc_id = module.vpc.vpc_id
  azs    = var.azs
  cidrs  = var.public_subnet_cidrs
  name   = var.env_name
}

module "private_subnet" {
  source       = "./private_subnet"
  vpc_id       = module.vpc.vpc_id
  azs          = var.azs
  cidrs        = var.private_subnet_cidrs
  nat_gateways = module.public_subnet.nat_gateways
  name         = var.env_name
}