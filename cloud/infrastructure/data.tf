# Get Availability Zones:
data "aws_availability_zones" "available_zones" {
  state = "available"
}