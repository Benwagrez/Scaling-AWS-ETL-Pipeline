# Base image https://hub.docker.com/u/rocker/
FROM rocker/r-base:latest

# Update image
RUN apt-get update -qq -y

## create directories
RUN mkdir -p /code

## copy files
COPY requirements.R /code/install_packages.R
COPY codepull.sh /code/codepull.sh

## install R-packages
RUN Rscript /code/install_packages.R
RUN sh /code/codepull.sh

## run the script
# CMD Rscript /code/myScript.R