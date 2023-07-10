# Service Accounts for Flyte and User Code
resource "google_service_account" "flyte_service_account" {
  account_id   = "flyte-sa"
  display_name = "Flyte Orchestrator Service Account"
}

resource "google_service_account" "user_code_service_account" {
  account_id   = "user-code-sa"
  display_name = "User Code Service Account"
}

resource "google_project_iam_custom_role" "flyte_backend_role" {
  role_id     = "flyte-backend-role"
  title       = "Flyte Backend Role"
  description = "Custom IAM role for the Flyte backend service"

  permissions = [
    "storage.objects.create",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.update",
    "storage.objects.delete",
    "sql.databases.create",
    "sql.databases.get",
    "sql.databases.update",
    "sql.databases.delete",
    "container.pods.create",
    "container.pods.get",
    "container.pods.list",
  ]
}

resource "google_project_iam_binding" "flyte_backend_role_binding" {
  role    = google_project_iam_custom_role.flyte_backend_role.name
  members = ["serviceAccount:${google_service_account.flyte_service_account.email}"]
}

resource "google_project_iam_member" "user_code_role_member" {
  role   = "roles/editor" # Adjust the role as needed
  member = "serviceAccount:${google_service_account.user_code_service_account.email}"
}

