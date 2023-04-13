provider "google" {
  project = local.id
  region  = local.region
}

provider "random" {

}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.48.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"

    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }

  }

  # Comment out if storage needs to be removed and recreated again
  # backend "gcs" {
  #   bucket = "pricing-aggregator-us-east1-terraform-state"
  #   # prefix = "terraform/state"
  # }
}