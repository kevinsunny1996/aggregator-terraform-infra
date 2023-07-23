######################################################################################################################
# This section creates the following resources
# 1 - GKE Cluster for Flyte
# 2 - Nodepool with 2 nodes each using e2-micro instances
# 3 - Helm Release for Flyte
# 4 - Auth client for getting CA certificate while authenticating to cluster
######################################################################################################################
resource "google_container_cluster" "flyte_basic_cluster" {
  name                     = "flyte-basic-cluster"
  location                 = "${local.region}-b"
  remove_default_node_pool = true
  initial_node_count       = 2

  node_config {
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    ephemeral_storage_local_ssd_config {
      local_ssd_count = 0
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  depends_on = [google_project_service.compute_api, google_project_service.container_api]
}


resource "google_container_node_pool" "flyte_basic_node_pool" {
  name       = "flyte-basic-np"
  location   = "${local.region}-b"
  cluster    = google_container_cluster.flyte_basic_cluster.name
  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 2
    max_node_count = 4
  }

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = google_service_account.flyte_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  depends_on = [google_project_service.compute_api, google_project_service.container_api]
}

resource "helm_release" "flyte_basic_cluster" {
  name             = "flyte-basic-setup"
  namespace        = "flyte"
  create_namespace = true
  repository       = "https://helm.flyte.org"
  chart            = "flyte-binary"
  version          = "v1.8.0"

  ################################################################################################################# 
  # Setting chart values to override the default in flyte-binary.yaml
  # Read more about the fields on the following reources
  # README - https://github.com/flyteorg/flyte/tree/master/charts/flyte-binary
  # YAML File reference - https://github.com/flyteorg/flyte/blob/master/charts/flyte-binary/values.yaml
  #################################################################################################################
  #################################################################################################################
  # The flyte-binary setup considers all the components bundled up into one and if your workflow isn't heavy , this is a good one to start.
  # Read the following doc to know more - https://docs.flyte.org/en/latest/deployment/deployment/index.html
  # This would need GCS and CloudSQL to be referenced and overriden in the values.yml file
  #################################################################################################################

  # Cloud SQL override values
  set {
    name  = "configuration.database.dbname"
    value = google_sql_database_instance.flyte_db_backend.name
  }

  set {
    name  = "configuration.database.host"
    value = google_sql_database_instance.flyte_db_backend.public_ip_address
  }

  set {
    name  = "configuration.database.password"
    value = google_sql_user.flyte_db_user.password
  }

  set {
    name  = "configuration.database.port"
    value = "5432"
  }

  set {
    name  = "configuration.database.username"
    value = google_sql_user.flyte_db_user.name
  }

  # GCS values override
  set {
    name  = "configuration.storage.metadataContainer"
    value = module.flyte_gcs_backend.name
  }

  set {
    name  = "configuration.storage.provider"
    value = "gcs"
  }

  set {
    name  = "configuration.storage.providerConfig.gcs.project"
    value = local.id
  }

  set {
    name  = "configuration.storage.userDataContainer"
    value = module.flyte_gcs_backend.name
  }


  depends_on = [google_container_cluster.flyte_basic_cluster, google_container_node_pool.flyte_basic_node_pool]
}