terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.28.0"
    }
  }
}

provider "google" {
  project                     = data.terraform_remote_state.bootstrap.outputs.project_id
  region                      = var.region
  zone                        = var.zone
  # impersonate_service_account = data.terraform_remote_state.bootstrap.outputs.terraform_sa_email todo did not have time
}