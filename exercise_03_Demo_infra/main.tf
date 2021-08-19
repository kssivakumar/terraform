provider "aws" {
  region = "ap-southeast-2"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}

resource "aws_vpc" "myinfra-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myinfra-subnet" {
  vpc_id = aws_vpc.myinfra-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name: "${var.env_prefix}-subnet-01"
  }
}

/*
###creating new route table
resource "aws_route_table" "myinfra-route-table" {
  vpc_id = aws_vpc.myinfra-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myinfra-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}
*/

## asssociate with default route route_table creating new one
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myinfra-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myinfra-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}
resource "aws_internet_gateway" "myinfra-igw" {
  vpc_id = aws_vpc.myinfra-vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}
/*
## Subnet asssociation for the new route table
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myinfra-subnet.id
  route_table_id = aws_route_table.aws_default_route_table.id
}
*/