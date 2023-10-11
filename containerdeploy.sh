#!/bin/bash

# Installing Python dependencies into packages and zipping the deployment for ETL Data Query
pip install --target ./packages/ETLDataQuery -r ./python/ETLDataRequirements.txt --no-user
7z a -tzip ./ETL_data_query_payload.zip ./packages/ETLDataQuery/*
7z a ./ETL_data_query_payload.zip ./python/ETLDataQuery/*

# Running Terraform apply
terraform apply -var-file="terraform.tfvars" -var="deploycontainer=true"

rm ETL_data_query_payload.zip