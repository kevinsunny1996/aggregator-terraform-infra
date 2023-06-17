# Create a Cloud SQL DB instance for Cloud Composer Backend
resource "google_sql_database_instance" "main" {
  name             = "composer-db-backend"
  database_version = "POSTGRES_14"
  region           = local.region

  settings {
    tier = "db-f1-micro"
    advanced_machine_features {
      disk_size = 10
      disk_type = "PD_HDD"
      activation_policy = "ON_DEMAND"
    }

  }

  depends_on = [ google_project_service.cloud_sql_api ]
}