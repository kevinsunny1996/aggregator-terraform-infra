# resource "google_container_cluster" "airflow_cluster" {
#   name = "${local.name}-airflow"
#   location = local.region
#   project = ""

#   remove_default_node_pool = true
#   initial_node_count = 1


# }