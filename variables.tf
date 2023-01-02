variable "aws_region" {
  default = "us-east-1"
}

variable "project_tags" {
  type = map(string)

  default = {
    project = "pricing-aggregator-infra"
  }
}

variable "project_name" {
  description = "Name of the project"
  default     = "pricing-aggregator"
}



# variable "availability_zones" {
#    type    = list(string)
#    default = ["us-east-1a", "us-east-1b", "us-east-1c"]
# }

variable "name" {
  description = "Name of VPC and EKS cluster"
  type        = string
  default     = "aggregator-data-pipeline"
}

variable "eks_cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.23"
}

variable "ml_artifact_project_name" {
  description = "MLFlow Project Name"
  type        = string
  default     = "mlflow"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "192.168.0.0/24"
}

variable "private_subnet_cidr_block" {
  default = "192.168.1.0/24"
}

variable "log_group_name" {
  default = "ecs/fargate"
}

# variable "image_version" {
#    default = "latest"
# }

# variable "metadata_db_instance_type" {
#    default = "db.t2.micro"
# }

# variable "celery_backend_instance_type" {
#    default = "cache.t2.small"
# }