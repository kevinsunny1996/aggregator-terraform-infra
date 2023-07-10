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

  }

  # Comment out if storage needs to be removed and recreated again
  backend "gcs" {
    bucket = "tf-state-tracker"
    # prefix = "terraform/state"
  }
}