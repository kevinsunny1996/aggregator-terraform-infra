#############################################################################################################
# GCS Bucket to store terraform state
#############################################################################################################
module "gcs_buckets" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "~> 3.4"
  project_id      = local.id
  location        = local.gs_region
  names           = ["terraform-state"]
  prefix          = local.name
  set_admin_roles = true
  # admins = ["group:${local.owner}"]
  versioning = {
    terraform-state = true
  }
  bucket_admins = {
    second = "user:${local.owner}"
  }

  labels = {
    project_name      = local.name
    project_workspace = local.id
  }
}

#############################################################################################################
# GCS bucket to store Airflow logs
#############################################################################################################
module "airflow_log" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "~> 3.4"
  project_id      = local.id
  location        = local.gs_region
  names           = ["airflow-run-logs"]
  prefix          = local.name
  set_admin_roles = true
  # admins = ["group:${local.owner}"]
  versioning = {
    airflow-run-logs = true
  }
  bucket_admins = {
    second = "user:${local.owner}"
  }

  labels = {
    project_name      = local.name
    project_workspace = local.id
  }
}