resource "google_composer_environment" "ds_orchestrator" {
  name   = "${local.name}-orchestrator"
  region = local.region
  config {

    environment_size = "ENVIRONMENT_SIZE_SMALL"

    workloads_config {
      scheduler {
        cpu        = 1
        memory_gb  = 1.875
        storage_gb = 1
        count      = 1
      }
      triggerer {
        cpu       = 1
        memory_gb = 1.875
        count     = 1
      }
      web_server {
        cpu        = 1
        memory_gb  = 1.875
        storage_gb = 2
      }
      worker {
        cpu        = 1
        memory_gb  = 1.875
        storage_gb = 1
        min_count  = 1
        max_count  = 4
      }
      software_config {
        image_version = "composer-2.3.4-airflow-2.5.3"
      }

      node_config {
        service_account = google_service_account.custom_composer_account.email
      }
    }
  }
}