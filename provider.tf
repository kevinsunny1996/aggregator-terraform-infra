provider "aws" {
  region = var.aws_region
}

terraform {
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.28.0"
    }
  }
  
  required_version = ">= 0.14.9"

  backend "remote" {
    hostname = "app.terraform.io"
    organization = "hotel-aggregator"

    workspaces {
      name = "aggregator-terraform-infra"
    }
  }
}

variable "project_tags" {
  type = map(string)

  default = {
    project = "pricing-aggregator-infra"
  }
}