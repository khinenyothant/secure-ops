#Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "vault-vpc"
  }
}

/*
======
PUBLIC
======
*/

#Create public subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_cidr_block)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

#Create public route table for public subnet
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public_subnet_rt"
  }
}

#Associate public route table with public subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet_rt.id
}

#Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vault-vpc GW"
  }
}

#define route in public route table 
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

/*
======
PRIVATE
======
*/

#Create private subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "private subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

#Create private route table for private subnet
resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private_subnet_rt"
  }
}

#Associate private route table with private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet_rt.id
}

#Create Elastic IP
resource "aws_eip" "lb" {
  domain = "vpc"
}

#Create nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "vault-vpc NAT GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#define route in private route table
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

/*
======
DB
======
*/

#Create db subnet
resource "aws_subnet" "db_subnet" {
  count             = length(var.db_cidr_block)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_cidr_block[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "db subnet-${element(data.aws_availability_zones.azs.names, count.index)}"
  }
}

#Create db route table for db subnet
resource "aws_route_table" "db_subnet_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "db_subnet_rt"
  }
}

#Associate db route table with db subnet
resource "aws_route_table_association" "db" {
  count          = length(var.db_cidr_block)
  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_subnet_rt.id
}

#define route in db route table
resource "aws_route" "db" {
  route_table_id         = aws_route_table.db_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

#create database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-group"
  subnet_ids = aws_subnet.db_subnet[*].id

  tags = {
    Name = "Vault Cluster DB subnet group"
  }
}