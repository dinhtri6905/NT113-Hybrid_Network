resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.project_name}-VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-IGW" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-Public-Subnet" }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  tags = { Name = "${var.project_name}-Private-Subnet" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id 
  tags = { Name = "${var.project_name}-NAT" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ==================================================
# HYBRID CLOUD: VPN Gateway (Site-to-Site VPN)
# ==================================================

# 1. Virtual Private Gateway (Đầu nối phía AWS)
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.main.id
  amazon_side_asn = 65000
  tags = { Name = "${var.project_name}-VGW" }
}

# 2. Customer Gateway (Đại diện cho IP thật của EVE-NG)
resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65001
  ip_address = var.on_prem_public_ip
  type       = "ipsec.1"
  tags = { Name = "${var.project_name}-CGW" }
}

# 3. Đường hầm VPN kết nối 2 đầu
resource "aws_vpn_connection" "main_vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = false # Dùng BGP
  tags = { Name = "${var.project_name}-VPN-Tunnel" }
}

resource "aws_subnet" "rds_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.rds_subnet_1_cidr
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = { Name = "${var.project_name}-RDS-Subnet-1" }
}

resource "aws_subnet" "rds_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.rds_subnet_2_cidr
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = { Name = "${var.project_name}-RDS-Subnet-2" }
}

# Gom 2 subnet này thành 1 nhóm cho Database
resource "aws_db_subnet_group" "rds_group" {
  name       = "vinhealth-rds-group"
  subnet_ids = [aws_subnet.rds_1.id, aws_subnet.rds_2.id]
  tags = { Name = "${var.project_name}-DB-Subnet-Group" }
}