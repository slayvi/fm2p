# Create VPC:
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
}


# Create Public Subnets:
resource "aws_subnet" "public" {
  count             = var.count_av_zones
  vpc_id            = aws_vpc.default.id
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name = "CP Public Subnet-${count.index + 1}"
  }
}


# Create Private Subnets:
resource "aws_subnet" "private" {
  count             = var.count_av_zones
  vpc_id            = aws_vpc.default.id
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index + var.count_av_zones)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name = "CP Private Subnet-${count.index + 1}"
  }
}


# Create Internet Gateway:
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}


# create Route Table for internet access: 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}


# Create Public Route Table Association: 
resource "aws_route_table_association" "public" {
  count          = var.count_av_zones
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
}


# Create Elastic IP:
resource "aws_eip" "natgateway" {
  count      = var.count_av_zones
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}


# Create NAT-Gateways:
resource "aws_nat_gateway" "natgateway" {
  count         = var.count_av_zones
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.natgateway.*.id, count.index)
}


# Create Private Route-Tables:
resource "aws_route_table" "private" {
  count  = var.count_av_zones
  vpc_id = aws_vpc.default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.natgateway.*.id, count.index)
  }
}


# Create Private Route Table Association:
resource "aws_route_table_association" "private" {
  count          = var.count_av_zones
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}