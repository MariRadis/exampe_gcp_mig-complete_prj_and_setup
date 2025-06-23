
output "global_ip" {
  description = "The allocated global IP address for the load balancer."
  value       = module.load_balancer.global_ip
}

output "http_url" {
  description = "HTTP URL to access the load-balanced service."
  value       = "http://${module.load_balancer.global_ip}"
}
