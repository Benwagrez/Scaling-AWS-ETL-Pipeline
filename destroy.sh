#!/bin/bash

# Installing Python dependencies into packages and zipping the deployment for ETL Data Query
pip install --target ./packages/ETLDataQuery -r ./python/ETLDataRequirements.txt --no-user
7z a -tzip ./ETL_data_query_payload.zip ./packages/ETLDataQuery/*
7z a ./ETL_data_query_payload.zip ./python/ETLDataQuery/*

# Set up core infrastructure
terraform destroy -var-file="terraform.tfvars"

# Cleaning up working directory
rm ETL_data_query_payload.zip