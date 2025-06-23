#!/bin/bash

# Get your current public IP
MY_IP=$(curl -4 -s ifconfig.me)

terraform plan -out=somefile.tfplan -var="ssh_source_ip=${MY_IP}/32"
terraform apply somefile.tfplan  #-auto-approve


#Are instances healthy?
#gcloud compute backend-services get-health web-backend --global
