output "public_subnets" {
  value = module.public_subnet.subnets
}

output "private_subnets" {
  value = module.private_subnet.subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}