resource "google_compute_network" "vpc" {
  name = "webapp-vpc"
  auto_create_subnetworks=false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = var.subnet_name
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}

resource "google_compute_router" "nat_router" {
  name    = var.router_name
  region  = var.region
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
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



resource "google_compute_firewall" "allow-lb-http" {
  name    = "allow-lb-http"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]  # Required for LB health checks and traffic todo

  target_tags   = var.network_tags

  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }

  description = "Allow HTTP traffic from GCP HTTP Load Balancer to backend"
}
resource "google_compute_firewall" "allow-iap-ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]  # IAP TCP tunneling range
  target_tags   = var.network_tags

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Allow IAP to SSH into instances"
}