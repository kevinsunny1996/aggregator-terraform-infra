# module "airflow_composer_v2" {
#   source  = "terraform-google-modules/composer/google//modules/create_environment_v2"
#   version = "~> 3.4"

#   project_id               = local.id
#   region                   = local.region
#   composer_env_name        = local.name
#   composer_service_account = google_service_account.airflow_composer_service_account.email
#   image_version            = "composer-2.1.5-airflow-2.4.3"
#   environment_size         = "ENVIRONMENT_SIZE_SMALL"

#   network                          = module.vpc.network_name
#   subnetwork                       = local.name
#   master_ipv4_cidr                 = var.composer_ip_ranges.master
#   service_ip_allocation_range_name = "services"
#   pod_ip_allocation_range_name     = "pods"
#   use_private_environment          = true
#   enable_private_endpoint          = true

#   airflow_config_overrides = {
#     secrets-backend = "airflow.providers.google.cloud.secrets.secret_manager.CloudSecretManagerBackend"
#   }

#   # env_variables = {

#   # }

#   # pypi_packages = {

#   # }

#   depends_on = [
#     module.vpc,
#     google_project_iam_member.airflow_composer_v2_extension
#   ]
# }  

# Composer instance for Airflow 
resource "google_composer_environment" "composer_environment" {
  name         = local.name
  region       = local.region
  config {
    node_count            = 3
    node_config {
      machine_type        = "n1-standard-1"
      disk_size_gb        = 50
      preemptible         = true
    }

    # https://cloud.google.com/composer/docs/concepts/versioning/composer-versions
    software_config {
      image_version       = "composer-2.3.0-airflow-2.5.1"
    }
    
  }
  depends_on = [google_storage_bucket.composer_bucket, google_sql_database_instance.composer_backend, google_project_service.composer_api]
}