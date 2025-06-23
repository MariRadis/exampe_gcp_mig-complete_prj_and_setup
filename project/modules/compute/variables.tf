variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "zone" {
  description = "The zone where resources will be deployed."
  type        = string
}

variable "subnetwork_id" {
  description = "The ID of the subnetwork to associate with the instance template."
  type        = string
}

variable "startup_script_path" {
  description = "Path to the startup script file."
  type        = string
}

variable "labels" {
  description = "Labels to apply to the instance template."
  type        = map(string)
}

# These are hardcoded in the resource block, but can be turned into variables if needed:
# name_prefix, machine_type, region, source_image, tags, etc.


variable "subnet_id" {
  default = ""
}