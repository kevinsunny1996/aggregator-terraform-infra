variable "gcp_region" {
  description = "Region for your GCP project to be located in"
  default     = "us-east1"
}

variable "owner_email" {
  description = "Owner email address"
  default     = "kevin.parasseril@gmail.com"
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
  default     = "invertible-fin-374508"
}

variable "ml_artifact_project_name" {
  description = "MLFlow Project Name"
  type        = string
  default     = "mlflow"
}
