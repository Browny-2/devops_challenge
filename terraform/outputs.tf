output "publisher_access_key" {
  value       = module.ecs_cluster.publisher_access_key
  description = "AWS_ACCESS_KEY to publish to ECR"
}

output "publisher_secret_key" {
  value       = module.ecs_cluster.publisher_secret_key
  description = "AWS_SECRET_ACCESS_KEY to upload to the ECR"
  sensitive   = true # Set to false for ease for this task. These outputs are made easily accessible so they can be used in the GitHub actions.
}

output "ecr_url" {
  value       = module.container_repository.ecr_url
  description = "The ECR repository URL"
}

output "app_url" {
  value       = module.ecs_application_load_balancer.app_url
  description = "The public ALB DNS"
}

output "rds_password" {
  value       = module.rds_instance.rds_password
  description = "Postges Password"
  sensitive   = true
}

output "rds_address" {
  value       = module.rds_instance.rds_address
  description = "Postgres RDS URL"
}