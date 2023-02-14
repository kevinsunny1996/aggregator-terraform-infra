resource "google_service_account" "airflow_composer_service_account" {
  account_id   = "composer-sa"
  display_name = "Composer Service Account"
}

resource "google_project_iam_member" "airflow_composer_worker" {
  project = local.id
  role    = "roles/composer.worker"
  member  = format("serviceAccount:%s", google_service_account.airflow_composer_service_account.email)
}

resource "google_project_iam_member" "airflow_composer_v2_extension" {
  project = local.id
  role    = "roles/composer.ServiceAgentV2Ext"
  member  = "serviceAccount:service-${data.google_project.e2eproject.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "airflow_composer_sa_user" {
  project = local.id
  role    = "roles/iam.serviceAccountUser"
  member  = format("serviceAccount:%s", google_service_account.airflow_composer_service_account.email)
}