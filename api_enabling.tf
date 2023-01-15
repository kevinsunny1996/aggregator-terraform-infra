resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "gcp_resource_manager" {
  project = local.id
  service = "cloudresourcemanager.googleapis.com"
}

