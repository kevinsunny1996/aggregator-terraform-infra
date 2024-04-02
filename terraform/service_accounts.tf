resource "google_service_account" "airflow_user_sa" {
  account_id   = "airflow-user-sa"
  display_name = "Custom Service Account for Astro Airflow User"
}


resource "google_project_iam_binding" "gcs_access" {
  project = local.id
  role    = "roles/storage.objectAdmin"
  members = ["serviceAccount:${google_service_account.airflow_user_sa.email}"]
}

resource "google_project_iam_binding" "bq_access" {
  project = local.id
  role    = "roles/bigquery.dataEditor"
  members = ["serviceAccount:${google_service_account.airflow_user_sa.email}"]
}

resource "google_project_iam_binding" "bq_job_creator" {
  project = local.id
  role    = "roles/bigquery.jobUser"
  members = ["serviceAccount:${google_service_account.airflow_user_sa.email}"]
}