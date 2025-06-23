#!/bin/bash

# Get your current public IP
MY_IP=$(curl -s ifconfig.me)

# Run Terraform with that IP as a variable
terraform apply -var="ssh_source_ip=${MY_IP}/32"  -auto-approve


