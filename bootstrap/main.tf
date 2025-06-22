
resource "google_project" "project" {
  name       = var.project_name
  project_id = var.project_id
  org_id     = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
  ])

  project = google_project.project.project_id
  service = each.key
  disable_on_destroy = false
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
  project      = google_project.project.project_id
}

terraform {
  backend "gcs" {
    bucket  = "terraform-state-bootstrap"
    prefix  = "bootstrap"
  }
}

#Responsibilities:
#Create GCP project
#
#Link to billing
#
#Enable APIs
#
#Create Terraform service account (and grant IAM roles)
#
#Output service account email & project ID