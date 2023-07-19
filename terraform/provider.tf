provider "google" {
  project = local.id
  region  = local.region
}

provider "random" {

}

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.flyte_cluster.endpoint}"
    token = data.google_client_config.default.access_token
  }

  depends_on = [google_container_cluster.flyte_cluster, google_container_node_pool.flyte_node_pool]
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.72.1"
    }

    # time = {
    #   source  = "hashicorp/time"
    #   version = "~> 0.9.1"

    # }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.1"
    }

  }

  # Comment out if storage needs to be removed and recreated again
  backend "gcs" {
    bucket = "tf-state-tracker"
    # prefix = "terraform/state"
  }
}