#!/bin/bash
set -e

echo "Deploying API Gateway..."

cd terraform
terraform init
terraform plan
terraform apply

echo "Deployment complete!"
terraform output
