#!/bin/bash

terraform apply -var="project_id=your-project-id" -var="domain_name=web.example.com"  -auto-approve
