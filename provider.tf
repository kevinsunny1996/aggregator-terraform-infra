provider "google" {
  project = ""
  region = ""
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.48.0"
    }
  }
}