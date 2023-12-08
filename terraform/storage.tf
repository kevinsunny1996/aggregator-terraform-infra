#############################################################################################################
# GCS Bucket to store extracted files from Spotify Web API
#############################################################################################################
module "gcs_api_extract" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "~> 3.4"
  project_id      = local.id
  location        = local.gs_region
  names           = ["rawg-api-extracts"]
  prefix          = local.name
  set_admin_roles = true
  #   admins          = ["group:${local.owner}"]
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
# GCS Bucket for Flyte orchestrator Backend
#############################################################################################################
# module "flyte_gcs_backend" {
#   source          = "terraform-google-modules/cloud-storage/google"
#   version         = "~> 3.4"
#   project_id      = local.id
#   location        = local.gs_region
#   names           = ["flyte-storage-backend"]
#   prefix          = local.name
#   force_destroy   = lookup()
#   set_admin_roles = true
#   #   admins          = ["group:${local.owner}"]
#   versioning = {
#     terraform-state = true
#   }
#   bucket_admins = {
#     second = "user:${local.owner}"
#   }

#   labels = {
#     project_name      = local.name
#     project_workspace = local.id
#   }
# }