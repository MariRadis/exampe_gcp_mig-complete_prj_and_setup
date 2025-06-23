
module "vpc" {
  source         = "./modules/vpc"
  region         = var.region
  vpc_name       = "webapp-vpc"
  subnet_name    = "webapp-subnet"
  ip_cidr_range  = "10.10.0.0/24"
  router_name    = "web-nat-router"
  nat_name       = "web-nat-config"
}

module "compute_mig_nginx" {
  source              = "./modules/compute"
  project_id          = var.project_id
  region              = var.region
  zone                = var.zone

  tags                = ["web"]
  labels              = {
    environment = "dev"
    app         = "web"
    deployed-by = "terraform"
  }
  subnetwork_id       = module.vpc.subnet_id
}

module "load_balancer" {
  source            = "./modules/load_balancer"
  instance_group    = module.compute_mig_nginx.instance_group
  health_check_id   = module.compute_mig_nginx.health_check_id
}
