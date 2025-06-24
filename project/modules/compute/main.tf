#done
resource "google_service_account" "vm_sa" {
  account_id   = "${var.base_instance_name}-vm-app-access"
  display_name = "Service Account for VM Access"
}
#done
resource "google_project_iam_member" "vm_sa_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/iam.serviceAccountUser",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}
#done



resource "google_compute_region_instance_template" "web_template" {

  name_prefix  = "${var.base_instance_name}-template"
  machine_type = "e2-medium"
  region       = var.region

  lifecycle {
    create_before_destroy = true
  }

  scheduling {
    provisioning_model = var.provisioning_model
    preemptible        = var.preemptible
    automatic_restart  = var.automatic_restart
  }

  tags   = var.network_tags
  labels = var.labels
  disk {
    boot         = true
    auto_delete  = true
    source_image = "debian-cloud/debian-12"
  }

  network_interface {
    subnetwork = var.subnet_id
  }

  metadata_startup_script = var.startup_script

  metadata = {
    enable-oslogin     = "TRUE"
    serial-port-enable = "true"
  }

  service_account {
    email = google_service_account.vm_sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}


#Ensures instances are healthy before serving traffic.
resource "google_compute_health_check" "hc" {
  name = "${var.base_instance_name}-health-check"

  http_health_check {
    port = 80
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 3
  unhealthy_threshold = 5
}


resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "${var.base_instance_name}-mig"
  base_instance_name = var.base_instance_name
  region             = var.region
  version {
    instance_template = google_compute_region_instance_template.web_template.id
  }
  update_policy {
    type = "PROACTIVE"       # Roll out changes immediately
    minimal_action = "REPLACE"         # Replace VMs
    max_surge_fixed = 3              # Allow 1 extra VM during update
    max_unavailable_fixed = 0                 # Keep all existing VMs running
  }
  named_port {
    name = "http"
    port = 80
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.hc.id
    initial_delay_sec = 90
  }
}


resource "google_compute_region_autoscaler" "web_autoscaler" {
  name   = "${var.base_instance_name}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web_mig.id
  autoscaling_policy {
    max_replicas = 5
    min_replicas = 1

    cpu_utilization {
      target = 0.6
    }

    load_balancing_utilization {
      target = 0.6
    }

    cooldown_period = 90  # cold start web-app. Needs to be same as initial_delay_sec
  }
}
