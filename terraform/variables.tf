variable "gcp_region" {
  description = "Region for your GCP project to be located in"
  default     = "us-east1"
}

variable "gcs_region" {
  description = "Region for your GCS bucket is located in for storing tfstate files"
  default     = "us-east1"
}

variable "owner_email" {
  description = "Owner email address"
  sensitive   = true
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

variable "project_id" {
  description = "Project ID for GCP Project"
  sensitive   = true
}

variable "project_number" {
  description = "Project Number for your workspace"
  sensitive   = true
}

# variable "ml_artifact_project_name" {
#   description = "MLFlow Project Name"
#   type        = string
#   default     = "mlflow"
# }

# variable "composer_ip_ranges" {
#   type        = map(string)
#   description = "Composer 2 runs on GKE, so inform here the IP ranges you want to use"
#   default = {
#     pods     = "10.0.0.0/22"
#     services = "10.0.4.0/24"
#     nodes    = "10.0.6.0/24"
#     master   = "10.0.7.0/28"
#   }
# }