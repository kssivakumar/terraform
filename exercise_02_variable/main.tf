## Provider helps to connected to AWS
provider "aws" {
  region = var.region
  access_key = "Provide access key"
  secret_key = "Provide secret key"
}

variable "region" {
  default = "ap-southeast-2"
}

variable "CIDR_Block" {
  description ="VPC CIDR block range to accommodate subnet"
  type = list(string)
}

/*
variable "CIDR_Block" {
  desscription = "CIDR Block as object instead of list of object"
  type = list(object({
    cidr_block = string
    name = string
  }))
*/

/*
variable "dev_subnet_01" {
  description = "Subnet CIDR block for first subnet"
}

variable "dev_subnet_02" {
  description = "Subnet CIDR block for second subnet"
}
*/
variable "environment" {
  description = "Define the environment variable like prod, dev or test"
}
## Step 1
## Create VPC with CIDRblock
resource "aws_vpc" "terraform-development-vpc" {
  cidr_block = var.CIDR_Block[0]
  tags = {
    Name: var.environment
  }  
}

# Step 2
### Create subnet for the above VPC
resource "aws_subnet" "terraform-dev-subnet-01" {
  vpc_id = aws_vpc.terraform-development-vpc.id
  cidr_block = var.CIDR_Block[1]
  availability_zone = "ap-southeast-2a" 
    tags = {
      Name: var.environment
  } 
}

#step 3
### Create resourse for the second subnet cidr_block
resource "aws_subnet" "terraform-dev-subnet-02" {
  vpc_id = aws_vpc.terraform-development-vpc.id
  cidr_block = var.CIDR_Block[2]
  availability_zone = "ap-southeast-2a"
  tags = {
    Name: var.environment
  }
}

/*
output "dev-terraform-development-vpc" {
  value = aws_vpc.terraform-development-vpc.id
}

output "dev-subnet-01-id" {
  value = aws_subnet.terraform-dev-subnet-01
}

output "dev-subnet-02-id" {
  value = aws_subnet.terraform-dev-subnet-02
}
*/