variable "region" {
  description = "The region in which to create regional resources like subnet, router, and NAT."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "webapp-vpc"
}

variable "subnet_name" {
  description = "The name of the subnetwork."
  type        = string
}

variable "ip_cidr_range" {
  description = "The IP CIDR range for the subnetwork."
  type        = string
}

variable "router_name" {
  description = "The name of the NAT router."
  type        = string
}

variable "nat_name" {
  description = "The name of the NAT configuration."
  type        = string
}



variable "source_ranges" {
  description = "Source ip address that are allowed for ssh to VMs"
  type        = list(string)
}
variable "network_tags" {
  description = "Network tags to associate with the VM instance template"
  type        = list(string)
}
