module "airflow_gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 24.1"

  description = "Airflow GKE cluster"
  name        = "${local.name}-gke-cluster"

  project_id                 = local.id
  region                     = local.region
  zones                      = ["${local.region}-a"]
  network                    = "vpc-01"
  subnetwork                 = "${local.region}-01"
  ip_range_pods              = "${local.region}-01-gke-01-pods"
  ip_range_services          = "${local.region}-01-gke-01-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  release_channel            = "STABLE"

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      node_locations     = "${local.region}-a"
      min_count          = 1
      max_count          = 5
      local_ssd_count    = 0
      spot               = false
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      enable_gcfs        = false
      enable_gvnic       = false
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "${local.name}-user@${local.id}.iam.gserviceaccount.com"
      preemptible        = false
      initial_node_count = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]

    project = [local.name]
  }
}

