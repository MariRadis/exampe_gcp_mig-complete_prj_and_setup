




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