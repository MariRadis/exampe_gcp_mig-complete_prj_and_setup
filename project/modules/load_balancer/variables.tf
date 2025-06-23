variable "instance_group" {
  description = "The instance group to associate with the backend service."
  type        = string
}

variable "health_check_id" {
  description = "The health check to associate with the backend service."
  type        = string
}
