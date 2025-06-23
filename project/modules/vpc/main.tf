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
