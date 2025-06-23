variable "project_id" {}
variable "region" {
  default = "europe-west1"
}
variable "zone" {
  default = "europe-west1-b"
}
variable "domain_name" {
  description = "Your fully qualified domain name (e.g. web.example.com)"
}

variable "ssh_source_ip" {
  description = "Public IP allowed to SSH into the instances"
  type        = string
}