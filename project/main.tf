resource "google_compute_network" "vpc" {
  name = "webapp-vpc"
  auto_create_subnetworks=false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "webapp-subnet"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}



resource "google_compute_router" "nat_router" {
  name    = "web-nat-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name                               = "web-nat-config"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


#done
resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web"]
}

#done
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["YOUR.IP.ADDRESS/32"] # todo add command to get my ip address
  target_tags = ["web"]
}

#done
resource "google_service_account" "vm_sa" {
  account_id   = "vm-app-access"
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

  name_prefix  = "web-template"
  machine_type = "e2-medium"
  region       = "europe-west-1"

  scheduling {provisioning_model = "spot"}

  tags = ["web"]
  labels = ["web", "deployed-from-terraform", "dev"] # this sholud be given as input values
  disk {
    boot         = true
    auto_delete  = true
    source_image = "debian-cloud/debian-12"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = file("startup-script.sh")
  metadata = {
    enable-oslogin = "TRUE"  # TODO check why this
  }

  service_account {
    email = google_service_account.vm_sa.email
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }
}
#Ensures instances are healthy before serving traffic.
resource "google_compute_health_check" "hc" {
  name = "web-health-check"

  http_health_check {
    port = 80
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}
#done
resource "google_compute_region_instance_group_manager" "web_mig" {
  name               = "web-mig"
  base_instance_name = "web"
  region = "europe-west1"
  version {
    instance_template = google_compute_region_instance_template.web_template.id
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

#done
resource "google_compute_autoscaler" "web_autoscaler" {
  name   = "web-autoscaler"
  zone   = var.zone
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

#Defines the backend pool of VMs and load balancing behavior.
resource "google_compute_backend_service" "web_backend" {
  name                  = "web-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"
  port_name             = "http"
  health_checks = [google_compute_health_check.hc.id] #Ensures instances are healthy before serving traffic.
  timeout_sec           = 10

  backend {
    group = google_compute_region_instance_group_manager.web_mig.instance_group
  }
}

#Maps requests (by path or host) to backend services.
resource "google_compute_url_map" "web_map" {
  name            = "web-map"
  default_service = google_compute_backend_service.web_backend.id
}

#Acts as the entry point for HTTP requests.
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_map.id
}

#Allocates a global public IP for the load balancer
resource "google_compute_global_address" "lb_ip" {
  name = "web-lb-ip"
}

#Routes incoming traffic on port 80 to the target proxy.
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name                  = "web-http-rule"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
}

output "http_url" {
  value = "http://${google_compute_global_address.lb_ip.address}"
}