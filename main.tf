provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnets" {
  count = 3
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = 3
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_association" {
  count = 3
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id
  description = "Allow HTTP and SSH"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-0005b192e8e17af5f"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnets[0].id
  security_groups = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "ansys_instance"
  }
}