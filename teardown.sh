#!/bin/bash

cd `dirname $0`
[[ -s ./env.rc ]] || exit 1
source ./env.rc

echo "======= terraform destroy ======="

cd terraform
terraform init
terraform destroy -force

cd ..

echo "======== destroying Wasabi ========"
wasabi/teardown.sh -p $WASABI_PROFILE -r $WASABI_REGION -b $WASABI_BUCKET

echo "======== tidying up ========"
rm -f terraform/terraform.tfvars 2>/dev/null
