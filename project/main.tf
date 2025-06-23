module "compute" {
  source              = "./modules/compute"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone

  name_prefix         = "web-template"
  machine_type        = "e2-medium"
  tags                = ["web"]
  labels              = {
    environment = "dev"
    app         = "web"
  }
  source_image        = "debian-cloud/debian-12"
  subnetwork_id       = module.vpc.subnet_id
  startup_script_path = "startup-script.sh"

  # Service account
  sa_account_id       = "vm-app-access"
  sa_display_name     = "Service Account for VM Access"
  sa_roles = [
    "roles/storage.objectViewer",
    "roles/iam.serviceAccountUser",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ]
  scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]

  mig_name            = "web-mig"
  base_instance_name  = "web"
  autoscaler_name     = "web-autoscaler"
}
