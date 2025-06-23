#!/bin/bash

# Get your current public IP
MY_IP=$(curl -s ifconfig.me)

terraform plan -var="ssh_source_ip=${MY_IP}/32" -out=somefile.tfplan

