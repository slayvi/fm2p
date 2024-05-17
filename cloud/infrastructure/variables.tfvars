# Assigning values to variables:

name_project = "FM2P"

name_bucket = "bucketfm2p"

name_author = "Slavka Fersch"

environment = "fm2p"

region = "eu-west-1"

vpc_cidr = "10.0.0.0/16"

count_av_zones = 2

app_count = 1

container_port = 5000

dockerfile_folder = "../application"

docker_image_tag = "latest"

cluster_name = "ml-cluster"

ecr_name = "ml-repository"

ecs_service = "ml-service"

container_name = "ml-container"

cpu = 256

memory = 2048 

alb_name = "lb"

ip_customer = ["0.0.0.0/0"] # default visible for all for presentation purpose
