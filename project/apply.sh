#!/bin/bash

# Get your current public IP
MY_IP=$(curl -s ifconfig.me)

terraform plan -out=somefile.tfplan -var="ssh_source_ip=${MY_IP}/32"
terraform apply somefile.tfplan  #-auto-approve
