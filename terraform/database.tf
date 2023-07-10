# Create a Cloud SQL DB instance for Cloud Composer Backend
resource "google_sql_database_instance" "flyte_db_backend" {
  name             = "flyte-db-backend"
  database_version = "POSTGRES_14"
  region           = local.region

  settings {
    tier = "db-f1-micro"

    # ip_configuration {
    #   require_ssl = true
    # }
    advanced_machine_features {
      disk_size         = 10
      disk_type         = "PD_HDD"
      activation_policy = "ALWAYS"
    }

  }

  depends_on = [google_project_service.cloud_sql_api]
}

resource "random_password" "flyte_db_password" {
  length           = 16
  special          = true
  override_special = "_@#"
}

resource "google_sql_user" "flyte_db_user" {
  name     = "postgres"
  instance = google_sql_database_instance.flyte_db_backend.name
  password = random_password.flyte_db_password.result
}