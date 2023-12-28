# Declare Providers AWS and Docker:
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}


# Configure AWS:
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Name        = var.name_project
      Author      = var.name_author
      Environment = var.environment
    }
  }
}




# Build and push Docker Container to AWS with Bash script:
resource "null_resource" "build_and_push" {

  provisioner "local-exec" {
    command = "./build.sh ${var.dockerfile_folder} ${aws_ecr_repository.main.repository_url}:${var.docker_image_tag} ${var.region}"
  }
}