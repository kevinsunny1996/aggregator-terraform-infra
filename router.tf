resource "google_compute_router" "router" {
    name = "router"
    region = local.region
    network = google_compute_network.main.id
}