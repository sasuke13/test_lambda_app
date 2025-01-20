#!/bin/bash

# Initialize Terraform without backend first
cd terraform
terraform init

# Apply to create S3 bucket
terraform apply -target=aws_s3_bucket.terraform_state -auto-approve

# Now uncomment the backend configuration in main.tf
sed -i 's/# backend/backend/' main.tf
sed -i 's/#   /  /' main.tf

# Reinitialize with S3 backend
terraform init -force-copy 