variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "zone" {
  description = "The zone where resources will be deployed."
  type        = string
}


variable "labels" {
  description = "Labels to apply to the instance template."
  type        = map(string)
}

variable "subnet_id" {
  description = "The ID of the subnetwork to associate with the instance template."
}

variable "region" {
}

variable "network_tags" {
  description = "Network tags to associate with the VM instance template"
  type        = list(string)
}

variable "base_instance_name" {
  type = string

}

variable "provisioning_model" {
}

variable "preemptible" {
}
variable "startup_script" {
  description = "Path to the startup script file"
  type        = string
}
variable "automatic_restart" {
}