output "aws_vpc_id" {
  description = "ID của VPC vừa tạo"
  value       = module.vinhealth_vpc.vpc_id
}

output "aws_public_subnet_id" {
  description = "ID của Public Subnet (Dành cho Web Server EHR)"
  value       = module.vinhealth_vpc.public_subnet_id
}

output "aws_vpn_connection_id" {
  description = "GỬI ID NÀY CHO TV3: ID của kết nối VPN Site-to-Site"
  value       = module.vinhealth_vpc.vpn_connection_id
}

output "web_public_ip" {
  value = aws_instance.web_ehr.public_ip
}