#############################################################################################################
# Airflow metadata DB
#############################################################################################################

# Random password to be created for Metadata DB
resource "random_password" "airflow_db_password" {
  length = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
# DB user
resource "google_sql_user" "airflow_user" {
  name = "orch@dataaggregator.com"
  instance = google_sql_database_instance.airflow_metadata.name
  type = "CLOUD_IAM_USER"
}

resource "google_secret_manager_secret_version" "airflow_db" {
  secret_id = "metadata_db_password"
  secret = random_password.airflow_db_password.result
}

# Airflow Metadata DB
resource "google_sql_database_instance" "airflow_metadata" {
  name = "airflow-postgres-db"
  region = local.region

  database_version = "POSTGRES_13"
  settings {
    tier = "db-f1-micro"
    disk_size = 10

    ip_configuration {
      require_ssl = true
    }

    database_flags {
      name = "cloudsql.iam_authentication"
      value = "on"
    }

    location_preference {
      zone = "${local.region}-a"
    }
  }
}