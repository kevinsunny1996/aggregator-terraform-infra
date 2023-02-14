resource "google_project_service" "composer_api" {
  provider = google
  project  = local.id
  service  = "composer.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "networking_api" {
  provider = google
  project  = local.id
  service  = "servicenetworking.googleapis.com"

  disable_on_destroy = false
}

