output "instance_template_id" {
  description = "The ID of the instance template."
  value       = google_compute_region_instance_template.web_template.id
}

output "instance_group" {
  description = "The managed instance group."
  value       = google_compute_region_instance_group_manager.web_mig.instance_group
}

output "health_check_id" {
  description = "The health check resource ID."
  value       = google_compute_health_check.hc.id
}

output "service_account_email" {
  description = "The service account email used by the instance template."
  value       = google_service_account.vm_sa.email
}
