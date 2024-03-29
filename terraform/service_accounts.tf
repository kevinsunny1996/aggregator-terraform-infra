# #####################################################################################################################
# # The following resource blocks does the following:
# # - Create a custom service account for Cloud Composer
# # - Bind the custom SA to worker role
# # - Add the Service Agent account as a new principal to workspace account and grant it the Service Agent role
# # - Read more on : https://cloud.google.com/composer/docs/composer-2/terraform-create-environments
# #####################################################################################################################
# resource "google_service_account" "custom_composer_account" {
#   account_id   = "composer-sa"
#   display_name = "Custom Service Account for Cloud Composer V2"
# }

# resource "google_project_iam_member" "composer_worker" {
#   project = local.id
#   member  = format("serviceAccount:%s", google_service_account.custom_composer_account.email)
#   # Roles for Public IP environments
#   role = "roles/composer.worker"
# }

# resource "google_service_account_iam_member" "composer_agent" {
#   service_account_id = google_service_account.custom_composer_account.name
#   role               = "roles/composer.ServiceAgentV2Ext"
#   member             = "serviceAccount:service-${local.number}@cloudcomposer-accounts.iam.gserviceaccount.com"
# }


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

resource "google_project_iam_binding" "gsm_access" {
  project = local.id
  role    = "roles/secretmanager.secretAccessor"
  members = ["serviceAccount:${google_service_account.airflow_user_sa.email}"]
}