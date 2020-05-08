#!/bin/bash
echo "======== configuring ========"

cd `dirname $0`
[[ -s ./env.rc ]] || exit 1

source ./env.rc

# setup tfvars to avoid need to pass things on the terraform command line
sed -e 's/^export //' -e's/=/="/' -e's/$/"/' ./env.rc | tr '[:upper:]' '[:lower:]' > terraform/terraform.tfvars

echo "======== building Wasabi ========"
wasabi/setup.sh -p $WASABI_PROFILE -r $WASABI_REGION -b $WASABI_BUCKET

echo "======== applying terraform ========"
cd terraform
terraform init
terraform apply -auto-approve
cd ..
