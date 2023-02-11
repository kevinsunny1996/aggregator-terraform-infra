resource "google_composer_environment" "data_aggregator_environment" {
  name = "data-aggregator-environment"

  config {
    software_config {
      image_version = "composer-2.1.5-airflow-2.4.3"
    }
    node_config {
      service_account = google_service_account.airflow_composer_service_account.email
    }
  }

  depends_on = [
    google_service_account.airflow_composer_service_account
  ]
}