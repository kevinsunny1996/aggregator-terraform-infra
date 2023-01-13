module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 3.4"
  project_id  = local.id
  location = local.region
  names = ["terraform-state"]
  prefix = local.name
  set_admin_roles = true
  admins = ["group:${local.owner}"]
  versioning = {
    terraform-state = true
  }
  bucket_admins = {
    second = "user:${local.owner}"
  }

  labels = {
    project_name = local.name
    project_workspace = local.id
  }
}