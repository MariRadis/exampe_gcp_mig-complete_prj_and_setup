#Responsibilities:
#Create GCP project
#
#Link to billing
#
#Enable APIs
#
# terraform deployment service account to be used in terraform deployment


import {
  id = var.project_id
  to = google_project.project
}

resource "google_project" "project" {
  name       = var.project_name
  project_id = var.project_id
  org_id     = var.org_id
  billing_account = var.billing_account_id
}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "networkmanagement.googleapis.com"
  ])

  project            = google_project.project.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
  project      = google_project.project.project_id
}

resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset([
    "roles/editor",
    "roles/compute.admin",
    "roles/compute.networkAdmin",
    "roles/monitoring.viewer",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/storage.admin"
    # "roles/resourcemanager.projectCreator" becasue I do not have org I do not have org admin
  ])



  project = google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_storage_bucket" "terraform_state" {
  name     = "tf-project-states"
  project  = var.project_id
  location = "EUROPE-WEST1"
  force_destroy = true

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

