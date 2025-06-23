output "backend_service_name" {
  description = "The name of the backend service."
  value       = google_compute_backend_service.web_backend.name
}

output "url_map_name" {
  description = "The name of the URL map."
  value       = google_compute_url_map.web_map.name
}

output "global_ip" {
  description = "The allocated global IP address for the load balancer."
  value       = google_compute_global_address.lb_ip.address
}

output "http_url" {
  description = "HTTP URL to access the load-balanced service."
  value       = "http://${google_compute_global_address.lb_ip.address}"
}
