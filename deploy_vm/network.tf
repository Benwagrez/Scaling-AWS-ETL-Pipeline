# ========================= #
# ====== Networking ======= #
# ========================= #
# Purpose
# Create networking to support EC2 and application load balancer
# Including network hardening resources for security

# AWS VPC 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Web VPC",
    })
  )}"  
}

# Subnets hosted in main AWS VPC
resource "aws_subnet" "compute_zonea" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = "us-east-2a"

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Compute Subnet A/Prod",
    })
  )}"  
}

resource "aws_subnet" "compute_zoneb" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.200.0/24"
  availability_zone = "us-east-2b"

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Compute Subnet B/Dev",
    })
  )}"  
}

# Route Table for internet gateway default route
resource "aws_route_table" "compute_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Compute route table",
    })
  )}"  
}

# Attaching route table to subnets
resource "aws_route_table_association" "route_table_assocA" {
  subnet_id      = aws_subnet.compute_zonea.id
  route_table_id = aws_route_table.compute_rt.id
}

resource "aws_route_table_association" "route_table_assocB" {
  subnet_id      = aws_subnet.compute_zoneb.id
  route_table_id = aws_route_table.compute_rt.id
}

# Creating internet gateway to allow bi-drectional traffic between public and private VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Web Internet Gateway",
    })
  )}"  
}

# Creating security group to restrict traffic to SSH and HTTPS
resource "aws_security_group" "ec2-sg" {
  name   = "Compute-security-group"
  vpc_id = aws_vpc.main.id
  ingress = [
    {
      # http port allowed from any ip
      description      = "RDP"
      from_port        = 3389
      to_port          = 3389
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null   
    },
    {
      # http port allowed from any ip
      description      = "RDP"
      from_port        = 3389
      to_port          = 3389
      protocol         = "UDP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null   
    }
  ]
  egress = [
    {
      description      = "all-open"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]
  tags = "${merge(
    var.common_tags,
    tomap({
      "Name" = "Web Network Security Gateway",
    })
  )}"  
}