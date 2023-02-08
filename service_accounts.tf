resource "google_service_account" "airflow_composer_service_account" {
  account_id   = "airflow-composer-service-account"
  display_name = "Composer Service Account"
}

resource "google_project_iam_member" "airflow_composer_service_account" {
  project = local.id
  member  = format("serviceAccount:%s", google_service_account.airflow_composer_service_account.email)
  role    = "roles/composer.worker"
}

resource "google_service_account_iam_member" "airflow_composer_service_account" {
  service_account_id = google_service_account.airflow_composer_service_account.name
  role                       = "roles/composer.ServiceAgentV2Ext"
  member                     = "serviceAccount:service-374508@cloudcomposer-accounts.iam.gserviceaccount.com"
}