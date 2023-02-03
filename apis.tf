resource "google_project_service" "compute" {
  service = "compute.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "secret" {
  service = "secretmanager.googleapis.com"
}