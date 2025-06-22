provider "google" {
  # Uses ADC (gcloud auth application-default login)
  impersonate_service_account = null
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.28.0"
    }
  }

  required_version = "> 1.9.0"
}