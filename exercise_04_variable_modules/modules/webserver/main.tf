resource "aws_default_security_group" "default-sg" {
  #name = "myinfra-sg"
  vpc_id = var.vpc_id

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
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
#Now deploy VM using AMI
resource "aws_instance" "myinfra-server" {
  ami = data.aws_ami.lastest-amazon-linux-image.id
  instance_type = var.instant_type

  subnet_id = var.subnet_id
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