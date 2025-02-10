provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.1.${count.index}.0/24"
  availability_zone = element(["ap-south-1a", "ap-south-1b", "ap-south-1c"], count.index)
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Web security group"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_instance" "ansys_instance" {
  ami                         = "ami-0005b192e8e17af5f"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  security_groups             = [aws_security_group.web_sg.name]
  associate_public_ip_address = true
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.web.id
  vpc  = true
}

