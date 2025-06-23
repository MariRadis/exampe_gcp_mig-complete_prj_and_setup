# GCP Web App with Load Balancer (Terraform)

This project deploys a simple NGINX-based web application on multiple Google Compute Engine (GCE) instances behind a 
global HTTP Load Balancer using Infrastructure as Code with Terraform.

## Features

- GCE virtual machines with startup script
- Managed Instance Group with auto-healing
- HTTP Load Balancer with health checks
- Secure and scalable VPC network with firewall rules
- Fully automated deployment via Terraform

## Prerequisites

- A Google Cloud project
- `gcloud` CLI authenticated
- Terraform >= 1.9 installed

## Usage

1. **Initialize Terraform:**

   ```bash
   terraform init
2.  Apply changes  
    ```bash
    [apply.sh](apply.sh)
3. Destroy after demonstration 
    ```bash
    [destroy.sh](destroy.sh)