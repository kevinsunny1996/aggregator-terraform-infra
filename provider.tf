provider "google" {
  project = local.id
  region  = local.region
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.airflow.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.airflow.ca_certificate)
}


provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.airflow.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.airflow.ca_certificate)
  }
}

provider "kubectl" {
  host                   = "https://${google_container_cluster.airflow.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.airflow.ca_certificate)
}

provider "random" {

}

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

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"

    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }

  }

  # Comment out if storage needs to be removed and recreated again
  backend "gcs" {
    bucket = "pricing-aggregator-us-east1-terraform-state"
    prefix = "terraform/state"
  }
}