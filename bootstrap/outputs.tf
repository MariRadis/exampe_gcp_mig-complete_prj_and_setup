
output "project_id" {
  value = google_project.project.project_id
}

output "terraform_sa_email" {
  value = google_service_account.terraform.email
}