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

resource "google_compute_firewall" "egress" {
  name    = "allow-egress"
  network = google_compute_network.vpc.name

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
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