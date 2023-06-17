# Create a Cloud SQL DB instance for Cloud Composer Backend
resource "google_sql_database_instance" "main" {
  name             = "composer-db-backend"
  database_version = "POSTGRES_14"
  region           = local.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }

  depends_on = [ google_project_service.cloud_sql_api ]
}