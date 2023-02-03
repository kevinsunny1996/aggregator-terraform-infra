# Required for retrieving access token from Terraform runner
data "google_client_config" "provider" {

}

data "google_container_cluster" "airflow_gke"{
    name = google_container_cluster.airflow.name
    location = local.region

    depends_on = [
      google_container_cluster.airflow
    ]
}