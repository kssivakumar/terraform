## Provider helps to connected to AWS
provider "aws" {
  region = var.region
  /*
  access_key = "your access value"
  secret_key = "your secret key value"
  */
}

variable "region" {
  default = "ap-southeast-2"
}

## Step 1
## Create VPC with CIDRblock
resource "aws_vpc" "terraform-development-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name: "Terraform-Development"
  }  
}

# Step 2
### Create subnet for the above VPC
resource "aws_subnet" "terraform-dev-subnet-1" {
  vpc_id = aws_vpc.terraform-development-vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-southeast-2a" 
    tags = {
    Name: "dev-subnet-1"
  } 
}

/*
## Below step added after executing step 1 and step 2
# Step 3
##Now if you want to create another subnet in existing VPC use data
data "aws_vpc" "Call_it_existing_VPC" {
  default = false
  id = "vpc-0b41acfc128f6770a"
}

#step 4
## Here we are reffering VPC created in previous step 1 in "data" as id
resource "aws_subnet" "terraform-dev-subnet-2" {
  vpc_id = aws_vpc.terraform-development-vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "ap-southeast-2a"
      tags = {
    Name: "dev-subnet-2"
  } 
}
*/

# Step 3
### Create second subnet for the above VPC
resource "aws_subnet" "terraform-dev-subnet-2" {
  vpc_id = aws_vpc.terraform-development-vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "ap-southeast-2a" 
    tags = {
    Name: "dev-subnet-2"
  } 
}

output "dev-terraform-development-vpc" {
  value = aws_vpc.terraform-development-vpc.id
}

output "dev-subnet-1-id" {
  value = aws_subnet.terraform-dev-subnet-1
}

output "dev-subnet-2-id" {
  value = aws_subnet.terraform-dev-subnet-2
}