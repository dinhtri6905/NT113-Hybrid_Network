// VPC, Subnet, Route Table, Internet GW, VPN Gateway, 
# ==================================================
# VPC
# ==================================================
resource "aws_vpc" "vpc_nt113" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "VPC-NT113-Group15"
  }
}

# ==================================================
# Internet Gateway
# ==================================================
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.vpc_nt113.id

 tags = {
    Name = "Internet-Gateway"
 }
}

# ==================================================
# Public Subnet
# ==================================================
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.vpc_nt113.id
    cidr_block = "10.0.1.0/24"
    # availability_zone = "?"
    map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }
}

# ==================================================
# NAT Gateway
# ==================================================
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-eip"
  }

  depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.private.id

  tags = {
    Name = "NAT-Gateway"
  }

  depends_on = [ aws_internet_gateway.igw ]
}

# ==================================================
# Private Subnet
# ==================================================
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.vpc_nt113.id
  cidr_block = "10.0.2.0/24"
  # availability_zone = "?"
  map_public_ip_on_launch = true

  tags = {
    Name = "Private-Subnet"
  }
}

# ==================================================
# Public Route Table
# ==================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_nt113.id
  
  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public
  route_table_id = aws_route_table.public.id
}

# ==================================================
# Private Route Table
# ==================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_nt113.id

  route {
    cidr_block = "10.0.2.0/24"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private
  route_table_id = aws_route_table.private.id
}
