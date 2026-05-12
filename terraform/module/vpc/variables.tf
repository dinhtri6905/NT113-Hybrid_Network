variable "vpc_cidr" {
  description = "Dải IP của VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Dải IP của Public Subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Dải IP của Private Subnet"
  type        = string
}

variable "on_prem_public_ip" {
  description = "IP Public của EVE-NG"
  type        = string
}

variable "project_name" {
  description = "Tên dự án"
  type        = string
}

variable "rds_subnet_1_cidr" {
  type = string
}

variable "rds_subnet_2_cidr" {
  type = string
}