# Service Account for the data processor (e.g., a Cloud Run service)
resource "google_service_account" "data_processor_sa" {
  account_id   = "data-processor-sa"
  display_name = "Data Processor Service Account"
}

# Service Account for the package builder (Cloud Build)
resource "google_service_account" "package_builder_sa" {
  account_id   = "package-builder-sa"
  display_name = "Package Builder Service Account"
}

# Grant the data processor SA the 'Cloud SQL Client' role
# This allows it to *connect* to the database, but not manage it
resource "google_project_iam_member" "processor_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.data_processor_sa.email}"
}