variable "sg_id" {
  description = "The id of the security group to apply the following rules to"
}

variable "source_cidr" {
  description = "The source CIDR block(s) to allow traffic from"
  default     = ["0.0.0.0/0"]
}