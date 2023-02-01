resource "helm_release" "airflow_helm_chart" {
  depends_on = [
    google_container_cluster.airflow
  ]

  repository       = "https://airflow.apache.org"
  chart            = "apache-airflow"
  name             = "apache-airflow"
  namespace        = "airflow"
  timeout          = 1800
  recreate_pods    = true
  reuse_values     = true
  create_namespace = true

  dependency_update = true
  lint              = true

  values = ["${file("airflow_values.yaml")}"]

}

resource "google_service_account" "airflow" {
  account_id = "airflow"
}