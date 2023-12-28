#!/bin/bash

# Fail fast:
set -e

# Getting Arguments:
build_folder=$1
aws_ecr_repository_url_with_tag=$2
aws_region=$3

# Connect to AWS:
aws ecr get-login-password --region $aws_region | docker login --username AWS --password-stdin $aws_ecr_repository_url_with_tag

# Build Image:
docker build -t $aws_ecr_repository_url_with_tag $build_folder

# Push Image:
docker push $aws_ecr_repository_url_with_tag