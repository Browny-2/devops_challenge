variable "cidr" { default = "10.10.0.0/20" }

module "base_network" {
  source = "./modules/network"

  cidr                 = var.cidr
  env_name             = "utrust"
  azs                  = slice(data.aws_availability_zones.available.names, 0, length(data.aws_availability_zones.available.names))
  public_subnet_cidrs  = format("%s,%s,%s", cidrsubnet(var.cidr, 6, 0), cidrsubnet(var.cidr, 6, 2), cidrsubnet(var.cidr, 6, 3))
  private_subnet_cidrs = format("%s,%s,%s", cidrsubnet(var.cidr, 6, 4), cidrsubnet(var.cidr, 6, 5), cidrsubnet(var.cidr, 6, 6))
}