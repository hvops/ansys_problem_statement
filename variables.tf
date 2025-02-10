variable "region" {
  description = "AWS region"
  default = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default = "ami-0005b192e8e17af5f"
}