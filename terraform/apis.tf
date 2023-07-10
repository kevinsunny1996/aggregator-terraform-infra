# Enable Composer v2 API
resource "google_project_service" "composer_api" {
  provider = google
  project  = local.id
  service  = "composer.googleapis.com"

  disable_on_destroy = false
}

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

# Compute API for GKE cluster
resource "google_project_service" "compute_api" {
  provider = google
  project  = local.id
  service  = "compute.googleapis.com"

  disable_on_destroy = false
}

# Cloud SQL API to create Flyte backend
resource "google_project_service" "cloud_sql_api" {
  provider = google
  project  = local.id
  service  = "sqladmin.googleapis.com"

  disable_on_destroy = false
}