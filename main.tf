terraform {
  required_version = "~> 1.16.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.23.0, < 8.0.0"
    }
  }
}

locals {
  application_name = "lol-service"
}

module "postgresql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 28.2"

  project_id           = var.project_id
  name                 = "pg-instance"
  random_instance_name = true
  database_version     = "POSTGRES_18"
  region               = "us-central1"
  deletion_protection  = false
}

module "artifact_registry" {
  source  = "GoogleCloudPlatform/artifact-registry/google"
  version = "~> 0.8"

  # Required variables
  project_id    = var.project_id
  location      = "us-central1"
  format        = "DOCKER"
  repository_id = local.application_name
}

module "cloud_run" {
  source = "GoogleCloudPlatform/cloud-run/google"
  # Locked to 0.20, allows minor updates – check for latest version
  version = "~> 0.32"

  # Required variables
  project_id   = var.project_id
  service_name = local.application_name
  location     = "us-central1"
  image        = "gcr.io/cloudrun/hello"
}

module "secret_manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.9"

  project_id = var.project_id

  secrets = [
    { name = "riot-api-key" },
  ]
}
