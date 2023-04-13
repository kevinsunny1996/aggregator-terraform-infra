#############################################################################################################
# GCS bucket to store Airflow logs
#############################################################################################################
# module "airflow_log" {
#   source          = "terraform-google-modules/cloud-storage/google"
#   version         = "~> 3.4"
#   project_id      = local.id
#   location        = local.gs_region
#   names           = ["airflow-run-logs"]
#   prefix          = local.name
#   set_admin_roles = true
#   # admins = ["group:${local.owner}"]
#   versioning = {
#     airflow-run-logs = true
#   }
#   bucket_admins = {
#     second = "user:${local.owner}"
#   }

#   labels = {
#     project_name      = local.name
#     project_workspace = local.id
#   }
# }

#############################################################################################################
# GCS Bucket to store extracted parquet files from RapidAPI
#############################################################################################################
# module "gcs_api_extract" {
#   source          = "terraform-google-modules/cloud-storage/google"
#   version         = "~> 3.4"
#   project_id      = local.id
#   location        = local.gs_region
#   names           = ["rapidapi-genius-api-extracts"]
#   prefix          = local.name
#   # set_admin_roles = true
#   # admins = ["group:${local.owner}"]
#   versioning = {
#     terraform-state = true
#   }
#   # bucket_admins = {
#   #   second = "user:${local.owner}"
#   # }

#   labels = {
#     project_name      = local.name
#     project_workspace = local.id
#   }
# }