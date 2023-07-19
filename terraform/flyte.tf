######################################################################################################################
# This section creates the following resources
# 1 - GKE Cluster for Flyte
# 2 - Nodepool with 2 nodes each using e2-micro instances
# 3 - Helm Release for Flyte
# 4 - Auth client for getting CA certificate while authenticating to cluster
######################################################################################################################
resource "google_container_cluster" "flyte_cluster" {
  name                     = "flyte-cluster"
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


resource "google_container_node_pool" "flyte_node_pool" {
  name       = "flyte-np"
  location   = "${local.region}-b"
  cluster    = google_container_cluster.flyte_cluster.name
  node_count = 2

  management {
    auto_repair = true
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
    taint = {
      key    = "instance_type"
      value  = "spot"
      effect = "NO_SCHEDULE"
    }
  }
  depends_on = [google_project_service.compute_api, google_project_service.container_api]
}

# resource "helm_release" "flyte_single_cluster" {
#   name       = "flyte-test-setup"
#   namespace  = "flyte"
#   repository = "https://flyteorg.github.io/flyte"
#   chart      = "flyte-binary"
#   version    = "v1.8.0"

#   depends_on = [google_container_cluster.flyte_cluster, google_container_node_pool.flyte_node_pool]
# }