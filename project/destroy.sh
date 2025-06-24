#!/bin/bash


MY_IP=$(curl -4 -s ifconfig.me)

terraform destroy  -var="ssh_source_ip=${MY_IP}/32"


https://35.244.193.90