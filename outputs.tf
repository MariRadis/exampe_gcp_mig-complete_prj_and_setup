output "lb_ip" {
  value = google_compute_global_address.lb_ip.address
}
output "https_url" {
  value = "https://${var.domain_name}"
}