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

### Cloud Build , CI / CD Pipeline ###

resource "google_service_account" "cloudbuild_sa" {
  account_id   = "g-cav-cloudbuild-sa"
  display_name = "G-CAV Cloud Build SA"
}

# Helper to get project details like the project number
data "google_project" "project" {}

# 1. Allow Cloud Build SA to write to the new Artifact Registry repo
resource "google_artifact_registry_repository_iam_member" "cloudbuild_repo_writer" {
  location   = google_artifact_registry_repository.docker_repo.location
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.writer"
  member     = google_service_account.cloudbuild_sa.member
}

# 2. Allow Cloud Build SA to deploy/update Cloud Run
resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = data.google_project.project.project_id
  role    = "roles/run.admin"
  member  = google_service_account.cloudbuild_sa.member
}

# 3. Allow Cloud Build SA to write logs
resource "google_project_iam_member" "cloudbuild_logging" {
  project = data.google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.cloudbuild_sa.member
}

# 4. Allow Cloud Build SA to 'act as' the data-processor-sa during deployment
resource "google_service_account_iam_member" "cloudbuild_actas_data_processor" {
  # Assumes your data-processor-sa resource is named 'data_processor_sa'
  service_account_id = google_service_account.data_processor_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.cloudbuild_sa.member
}

# 5. Allow Google's *agent* to use your *user-managed* SA
# (This is the 'serviceAccountTokenCreator' role you added)
resource "google_project_iam_member" "cloudbuild_agent_token_creator" {
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}