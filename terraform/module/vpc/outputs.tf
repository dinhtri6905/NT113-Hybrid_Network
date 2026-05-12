output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.main_vpn.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_group.name
}