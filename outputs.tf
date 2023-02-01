##########################################################################################################################
# Airflow Metadata DB values
##########################################################################################################################
output "db_user" {
  value = google_sql_user.airflow_user.name
}

output "db_pass" {
  sensitive = true
  value     = random_password.airflow_db_password.result
}

output "db_host" {
  value = google_sql_database_instance.airflow_metadata.connection_name
}

output "db_name" {
  value = google_sql_database_instance.airflow_metadata.name
}

##########################################################################################################################
# Airflow Service Account 
##########################################################################################################################
output "airflow_service_account" {
  value = google_service_account.airflow.email
}

##########################################################################################################################
# Airflow Logs GCS bucket
##########################################################################################################################
output "gcs_bucket_name" {
  value = module.airflow_log.name
}