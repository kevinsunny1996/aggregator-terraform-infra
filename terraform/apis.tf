# resource "google_project_service" "composer_api" {
#   provider = google
#   project  = local.id
#   service  = "composer.googleapis.com"

#   disable_on_destroy = false
# }

# resource "google_project_service" "networking_api" {
#   provider = google
#   project  = local.id
#   service  = "servicenetworking.googleapis.com"

#   disable_on_destroy = false
# }

# Secrets manager API enabling to store keys
resource "google_project_service" "secret_mgr_api" {
  provider = google
  project  = local.id
  service  = "secretmanager.googleapis.com"

  disable_on_destroy = false
}

# Container API to store cloud run images
resource "google_project_service" "container_api" {
  provider = google
  project  = local.id
  service  = "container.googleapis.com"

  disable_on_destroy = false
}