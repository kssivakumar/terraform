provider "aws" {
  region = "ap-southeast-2"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_home_ip" {}
variable "instant_type" {}
/*variable "mypublic_key_location" {}
*/
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
#Defining security group for the network
resource "aws_default_security_group" "default-sg" {
  #name = "myinfra-sg"
  vpc_id = aws_vpc.myinfra-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_home_ip]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}


#Now deploy VM using AMI
data "aws_ami" "lastest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values =["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


#Now deploy VM using AMI

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.lastest-amazon-linux-image.id
  instance_type = var.instant_type
  
  subnet_id = aws_subnet.myinfra-subnet.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = "ssh-terraform-learning"
  user_data = <<EOF
        #!/bin/bash
        sudo yum update -y
        sudo amazon-linux-extras install docker
        sudo service docker start
        sudo usermod -a -G docker ec2-user
        docker run -p 8080:80 nginx      
  EOF
  #The above user input can be provided in shell script format file as below
  #user_data = file("scriptname.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

#Install docker container to AMI create above
#Execute command while deploying VM


output "public_ip" {
  value = aws_instance.myapp-server.public_ip

}




#creating keypair instead of doing in manually
/*
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = "${file(var.mypublic_key_location)}"
}
*/
/*

output "aws_ami_id" {
  value = data.aws_ami.lastest-amazon-linux-image.id
}
*/
