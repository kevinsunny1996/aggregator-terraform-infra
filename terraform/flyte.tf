# TODO - Create GKE cluster post enabling relevant APIs 
resource "google_container_cluster" "flyte_cluster" {
  name                     = "flyte-cluster"
  location                 = "${local.region}-b"
  remove_default_node_pool = true
  initial_node_count       = 2
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    disk_size_gb = 10
    disk_type    = "pd-balanced"
    ephemeral_storage_local_ssd_config {
      local_ssd_count = 0
    }
  }
  depends_on = [google_project_service.compute_api, google_project_service.container_api]
}

resource "google_container_node_pool" "flyte_node_pool" {
  name       = "flyte-np"
  location   = "${local.region}-b"
  cluster    = google_container_cluster.flyte_cluster.name
  node_count = 2
  node_config {
    preemptible     = true
    machine_type    = "e2-micro"
    service_account = google_service_account.flyte_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  depends_on = [google_project_service.compute_api, google_project_service.container_api]
}

resource "helm_release" "flyte_single_cluster" {
  name       = "flyte-test-setup"
  namespace  = "flyte"
  repository = "https://flyteorg.github.io/flyte"
  chart      = "flyteorg/flyte-binary"
  version    = "0.1.10"
}