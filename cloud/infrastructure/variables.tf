#Creating Variables:

variable "name_bucket" {
  description = "Name of Bucket"
  type        = string
}


variable "name_project" {
  description = "Defining the Name of the Project"
  type        = string
}


variable "name_author" {
  description = "Defining the Name of the Author"
  type        = string
}


variable "environment" {
  description = "Definition of the environment"
  type        = string
}


variable "region" {
  description = "Region where the Infrastructure will be deployed"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR of the VPC"
  type        = string
}


variable "count_av_zones" {
  description = "Number of desired Availability Zones"
  type        = number
}


variable "app_count" {
  description = "Numbers of tasks running at the same time"
  type        = number
}


variable "container_port" {
  description = "Port for Flask Application"
  type        = number
}


variable "dockerfile_folder" {
  description = "Folder which contains the Dockerfile"
  type        = string
}


variable "docker_image_tag" {
  description = "Tag for Dockerimage"
  type        = string
}


variable "cluster_name" {
  description = "The name of an ECS cluster"
  type        = string
}


variable "ecr_name" {
  description = "Name of the Repository."
  type        = string
}


variable "ecs_service" {
  description = "Name of ECS Service."
  type        = string

}


variable "container_name" {
  description = "Name of the container."
  type        = string
}


variable "cpu" {
  description = "CPU the Fargate task should run with."
  type        = number
}


variable "memory" {
  description = "Memory the Fargate task should run with."
  type        = number
}


variable "alb_name" {
  description = "Name of the Load Balancer"
  type        = string
}


variable "ip_customer" {
  description = "IP of customer warehouse - [\"0.0.0.0/0\"] for illustrative purposes within the course fm2p"
  type        = list(string)
}