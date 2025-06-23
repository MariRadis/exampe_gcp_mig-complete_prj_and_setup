
module "vpc" {
  source         = "./modules/vpc"
  region         = var.region
  vpc_name       = "webapp-vpc"
  subnet_name    = "webapp-subnet"
  ip_cidr_range  = "10.10.0.0/24"
  router_name    = "web-nat-router"
  nat_name       = "web-nat-config"
  source_ranges = [var.ssh_source_ip]
  network_tags                = ["web"]
}

module "compute_mig_nginx" {
  source              = "./modules/compute"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone

  network_tags                = ["web"]
  labels              = {
    environment = "dev"
    app         = "web"
    deployed-by = "terraform"
  }
  subnet_id       = module.vpc.subnet_id
  base_instance_name = "web"
  provisioning_model = "STANDARD"
  preemptible = false
  automatic_restart= true
  startup_script = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from $(hostname)" > /var/www/html/index.nginx-debian.html
EOT

}

module "load_balancer" {
  source            = "./modules/load_balancer"
  instance_group    = module.compute_mig_nginx.instance_group
  health_check_id   = module.compute_mig_nginx.health_check_id
}
