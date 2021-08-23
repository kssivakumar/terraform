provider "aws" {
  region = "ap-southeast-2"
}
resource "aws_vpc" "myinfra-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}
module "myinfra-subnet" {
  source = "./modules/subnet" 
  avail_zone = var.avail_zone
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
  vpc_id =  aws_vpc.myinfra-vpc.id
  vpc_cidr_block = var.vpc_cidr_block
  default_route_table_id = aws_vpc.myinfra-vpc.default_route_table_id
}

module "myinfra-server" {
    source = "./modules/webserver"
    vpc_id =  aws_vpc.myinfra-vpc.id
    my_home_ip = var.my_home_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    instant_type = var.instant_type
    subnet_id =  module.myinfra-subnet.subnet.id
    avail_zone = var.avail_zone
}
/*
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

  subnet_id = module.myapp-subnet.subnet.id
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

  tags = {
    Name = "${var.env_prefix}-server"
  }
}
*/