resource "google_bigquery_dataset" "rawg_api_dataset" {
    dataset_id = "rawg_api_elt_dataset"
    project    = local.id
    location   = local.region
    delete_contents_on_destroy = true
}