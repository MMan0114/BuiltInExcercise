#Initialize the AWS terraform provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider aws {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

#Grab the latest AMI from AWS
data "aws_ami" "aws-linux" {
owners      = ["amazon"]
most_recent = true

  filter {
      name   = "name"
      values = ["amzn-ami-hvm* "]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }

  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

# Define the VPC
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"
}


# Define the private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-1b"
}

# Define the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.default.id}"
}

# Define the route table
resource "aws_route_table" "builtin_routetable" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "route_table_apache" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.builtin_routetable.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "builtin_securitygroup" {
  name = "builtin_secgroup"
  description = "Allow incoming/Outgoing HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"
}

# Define SSH key pair for our instances
resource "aws_key_pair" "default" {
  key_name = "apache_example"
  public_key = "${file("${var.key_path}")}"
}

#Create an EC2 Instance and install Apache
resource "aws_instance" "builtin-apache-instance" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.default.id}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.builtin_securitygroup.id}"]
  associate_public_ip_address = true
  source_dest_check = false
  user_data = "${file("install.sh")}"
  tags = "apache_server"
}

#output the public IP address to access the webserver 
output "EC2 Instance IP" {
  value = aws_instance.builtin_apace-instance.public_ip
}