provider "google" {
  project = local.id
  region  = local.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# provider "helm" {

# }

# provider "kubectl" {
#   host = "https://${module.gke.endpoint}"
#   token = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gke.ca_certificate)
# }

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.48.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }

    # helm = {
    #   source = "hashicorp/helm"
    #   version = "~> 2.8.0"
    # }

    # kubectl = {
    #   source = "gavinbunney/kubectl"
    #   version = "~> 1.14.0"
    # }

  }

  # Comment out if storage needs to be removed and recreated again
  backend "gcs" {
    bucket = "pricing-aggregator-us-east1-terraform-state"
    prefix = "terraform/state"
  }
}