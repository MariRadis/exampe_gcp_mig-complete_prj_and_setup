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
    "roles/resourcemanager.projectCreator"
  ])



  project = google_project.project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.terraform.email}"
}


#Responsibilities:
#Create GCP project
#
#Link to billing
#
#Enable APIs
#
#Create Terraform service account (and grant IAM roles)
#roles/compute.admin	Full control over Compute Engine resources (instances, templates, MIGs, load balancers)
#roles/compute.networkAdmin	Manage networks, subnets, and firewalls
#roles/iam.serviceAccountUser	Attach service accounts (like vm_sa) to VMs and templates
#roles/monitoring.viewer	Needed if autoscaler or instance health policies inspect metrics
#
#Output service account email & project ID
