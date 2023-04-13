provider "google" {
  project = ""
  region  = ""
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.48.0"
    }
  }

  # Comment out if storage needs to be removed and recreated again
  backend "gcs" {
    bucket = "pricing-aggregator-us-east1-terraform-state"
    prefix = "terraform/state"
  }
}