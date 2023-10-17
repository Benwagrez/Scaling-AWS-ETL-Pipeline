#!/bin/bash
# Setting env vars
export ACCOUNT=194189783006 
export REGION=us-east-2 
export REPO=rcontainerbin371298372

# Installing Python dependencies into packages and zipping the deployment for ETL Data Query
pip install --target ./packages/ETLDataQuery -r ./python/ETLDataRequirements.txt --no-user
7z a -tzip ./ETL_data_query_payload.zip ./packages/ETLDataQuery/*
7z a ./ETL_data_query_payload.zip ./python/ETLDataQuery/*

# Set up core infrastructure
terraform apply -var-file="terraform.tfvars" -var="deploycontainerregistry=true"

# Start docker build
source ./docker/dockerbuild.sh

# Running Terraform apply
terraform apply -var-file="terraform.tfvars" -var="deploylambda=true"

# Cleaning up working directory
rm ETL_proc_action_payload.zip
rm ETL_data_query_payload.zip