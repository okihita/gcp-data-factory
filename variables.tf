variable "project_id" {
  description = "The GCP project ID to deploy to."
  type        = string
  default     = "arm-ai-hackathon" # Change this
}

variable "region" {
  description = "The GCP region for resources."
  type        = string
  default     = "us-central1" # Example region
}

variable "db_password" {
  description = "Password for the Cloud SQL database user."
  type        = string
  sensitive   = true
  # Note: For a real project, inject this via a secret manager or .tfvars
  # For this hackathon, you can set a default for testing
  default = "a-S3cure-Password!"
}