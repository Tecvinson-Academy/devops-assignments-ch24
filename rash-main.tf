#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Define variables for the Ubuntu AMI ID and user data script
variable "ami_id" {
  default = "ami-0dba2cb6798deb6d8" # Ubuntu 20.04 LTS AMI ID (update as per the region)
}

variable "rash_password" {
  default = "password123"
}
variable "user_data_script" {
  default = <<-EOF
                #!/bin/bash
                apt update -y
                apt install nginx -y
                systemctl start nginx
                systemctl enable nginx
                EOF
}
data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "rash_sg" {
  vpc_id      = aws_vpc.rash_vpc.id # Explicitly link to the correct VPC
  name        = "rash-sg"
  description = "security group for rash"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.rash_sg.id]

  tags = {
    Name = "rash-ec2"
  }
}


resource "aws_instance" "web1" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.medium"

  vpc_security_group_ids = [aws_security_group.rash_sg.id]

  tags = {
    Name = "rash-ec3"
  }
}


#create vpc
resource "aws_vpc" "rash_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rash-vpc"
  }
}

#create subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.rash_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Specify a valid AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "rash-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.rash_vpc.id
  cidr_block        = "10.0.2.0/24" # Use a different CIDR block for private subnet
  availability_zone = "us-east-1b"  # Specify a valid AZ

  tags = {
    Name = "rash-private-subnet"
  }
}

#create internet gateway
resource "aws_internet_gateway" "rash_gw" {
  vpc_id = aws_vpc.rash_vpc.id

  tags = {
    Name = "rash-gw"
  }
}

#create route table
resource "aws_route_table" "rash_route_table" {
  vpc_id = aws_vpc.rash_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #Internet-bound traffic
    gateway_id = aws_internet_gateway.rash_gw.id
  }

  tags = {
    Name = "rash-route-table"
  }
}

#create route table association
resource "aws_route_table_association" "rash_ta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rash_route_table.id
}

#nginx instance
resource "aws_instance" "nginx" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  user_data              = var.user_data_script
  vpc_security_group_ids = [aws_security_group.rash_sg.id]

  tags = {
    Name = "rash-ec4"
  }
}

#create database instance
resource "aws_db_instance" "rash_mydb" {
  allocated_storage   = 20
  db_name             = "rashmydb"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = var.rash_password
  skip_final_snapshot = true
}

#Output the public IP of the NGINX instance
output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip

}