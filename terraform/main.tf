terraform {

  backend "s3" {
//    bucket = "utrust-terraform-michael-brown"
    key    = "statefile/"
    region = "eu-central-1"
  }

  required_version = ">=1.0.0"
  required_providers {
    aws = {
      version = ">= 3.46.0"
      source  = "hashicorp/aws"
    }
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}