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

variable "ssh_source_ip" {
  description = "Your public IP address to allow SSH access, in CIDR format (e.g. 1.2.3.4/32)."
  type        = string
}

variable "tags" {
  description = "Network tags to associate with the VM instance template"
  type        = list(string)
}
