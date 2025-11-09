terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. GCS (like S3)
resource "google_storage_bucket" "data_landing_zone" {
  name          = "${var.project_id}-data-landing-zone"
  location      = "US" # Multi-region for high availability
  force_destroy = true # Good for hackathons, allows easy deletion
}

# 2. Pub/Sub (like SNS/EventBridge)
resource "google_pubsub_topic" "file_uploads" {
  name = "file-uploads-topic"
}

# 3. Cloud SQL (like RDS)
# Note: This is the most expensive resource. 'db-f1-micro' is the smallest.
resource "google_sql_database_instance" "master_db_instance" {
  name             = "g-cav-master-db-instance"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    # Make it publicly accessible for easy hackathon access
    # WARNING: Do not do this for production. Use Private IP.
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
        name  = "allow-all"
      }
    }
  }
}

# Create the actual database inside the instance
resource "google_sql_database" "master_db" {
  name     = "g-cav-master-db"
  instance = google_sql_database_instance.master_db_instance.name
}

# Create a user for your data processor
resource "google_sql_user" "data_processor_user" {
  name     = "data_processor"
  instance = google_sql_database_instance.master_db_instance.name
  password = var.db_password
}