#!/bin/bash
set -e

echo "WARNING: This will destroy all resources!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" == "yes" ]; then
  cd terraform
  terraform destroy
  echo "Resources destroyed!"
else
  echo "Aborted."
fi
