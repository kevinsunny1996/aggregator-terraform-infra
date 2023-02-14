module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = local.id
  network_name = local.name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "subnet-${local.name}"
      subnet_ip             = var.composer_ip_ranges.nodes
      subnet_region         = local.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    "${local.name}-secondary" = [
      {
        range_name    = "pods"
        ip_cidr_range = var.composer_ip_ranges.pods
      },
      {
        range_name    = "services"
        ip_cidr_range = var.composer_ip_ranges.services
      },
    ]
  }

  depends_on = [
    google_project_service.networking_api
  ]
}

resource "google_compute_global_address" "service_range" {
  name          = "service-networking-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.200.0.0"
  prefix_length = 16
  network       = module.vpc.network_name
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_compute_router" "nat_router" {
  name    = "${module.vpc.network_name}-nat-router"
  network = module.vpc.network_self_link
  region  = local.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${module.vpc.network_name}-nat-router"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}