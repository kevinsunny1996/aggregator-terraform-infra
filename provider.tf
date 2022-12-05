provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.28.0"
    }
  }

  # Uncomment this code and run terraform init to get the local state transferred to S3
  # backend "s3" {
  #   bucket = "aggregator-infra-state"
  #   key = "terraform.tfstate"
  #   region = var.aws_region
  #   encrypt = true
  # }
}

