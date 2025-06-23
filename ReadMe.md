

# GCP Web App with Load Balancer (Terraform)

This project deploys a simple NGINX-based web application on Google Compute Engine (GCE) instances behind a **Global HTTP Load Balancer**, using **Terraform** for full automation.

## 🌟 Features

- GCE VMs running NGINX via startup script
- Managed Instance Group (MIG) with auto-healing
- Global HTTP Load Balancer with health checks
- VPC network with NAT, subnet, and firewall rules
- Modular and reusable Terraform structure

## ✅ Prerequisites

- A Google Cloud Platform (GCP) project
- Authenticated with the [`gcloud`](https://cloud.google.com/sdk/docs/install) CLI
- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.9 or newer installed

## 📦 Project Structure

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/                # Creates VPC, subnet, firewall, NAT
│   ├── compute/            # Creates instance template, MIG, health check
│   └── load_balancer/      # Sets up backend service, URL map, proxy, forwarding rule
├── apply.sh
└── destroy.sh
```

## 🚀 Usage

1. **Initialize Terraform:**

   ```bash
   terraform init
   ```

2. **Apply the infrastructure:**

   ```bash
   ./apply.sh
   ```

   > This script runs `terraform plan` and `terraform apply` with dynamic IP-based firewall rules for SSH.

3. **Access the web app:**

   After apply completes, open your browser to:

   ```bash
   echo "$(terraform output -raw http_url)"
   ```

   You should see NGINX serving:
   `Hello from <instance-hostname>`

4. **Kill VM and wait to recreate**
   1. We have 1 VM.
      ```bash
      gcloud compute instances list
      # Replace <instance-name> and <zone> with values from:

      gcloud compute instances delete web-nb7h  --zone=europe-west1-c --quiet
      
      ```
   2. Shows :
      1. mig recreating, vm auto heal https://console.cloud.google.com/compute/instanceGroups/list?hl=en&inv=1&invt=Ab06tQ&project=whitelama&supportedpurview=project,organizationId,folder
      2. new VM appears https://console.cloud.google.com/compute/instances?hl=en&inv=1&invt=Ab06tQ&project=whitelama&supportedpurview=project,organizationId,folder
      3. load balancer works
      ```bash
      echo "$(terraform output -raw http_url)"
      ```



5. **ssh** 
      ```bash
      gcloud compute instances list
      gcloud compute ssh web-nb7h --zone=europe-west1-c

      ```
   Test inside the VM
    ```bash
   curl localhost
   sudo systemctl status nginx
   exit
   ```

```
gcloud compute ssh web-nb7h  --project=whitelama  --zone=europe-west1-c   --tunnel-through-iap   --troubleshoot   --verbosity=debug
```



6. **Autoscaling**

7. **Firewall**

8. **Tear down the demo:**

   ```bash
   ./destroy.sh
   ```

## 🔐 Security

* SSH access is restricted to your public IP via `source_ranges`.
* Health check and load balancer IPs are explicitly allowed via firewall rules.
* No public IPs are assigned to VMs — traffic flows only through the load balancer.

## 🧠 Notes

* This uses [Google Global External HTTP Load Balancer](https://cloud.google.com/load-balancing/docs/https).
* `nginx` is installed via a simple `startup_script`.
* VM group is configured via a regional MIG for high availability.
* All modules are fully decoupled and can be reused across other GCP projects.

## 📄 License

MIT License

