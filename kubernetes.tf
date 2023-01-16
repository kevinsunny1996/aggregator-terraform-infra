data "google_project" "project" {
  
}

resource "google_container_cluster" "airflow_gke" {
    name = "airflow_gke"
    location = "${local.region}-a"
    remove_default_node_pool =   true
    initial_node_count = 1
    network = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.private.self_link
    networking_mode = "VPC_NATIVE"

    addons_config {
      http_load_balancing {
        disabled = true
      }
      horizontal_pod_autoscaling {
        disabled = false
      }
    }

    release_channel{
        channel = "STABLE"
    }

    workload_identity_config {
      workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
    }

    ip_allocation_policy {
      enable_private_nodes = true
      enable_private_endpoint = false
      master_ipv4_cidr_block = "172.16.0.0/28"
    }
}