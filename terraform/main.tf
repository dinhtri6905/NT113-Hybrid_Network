module "vinhealth_vpc" {
  source = "./module/vpc"

  vpc_cidr            = "10.200.0.0/16"      
  public_subnet_cidr  = "10.200.10.0/24"     
  private_subnet_cidr = "10.200.20.0/24"     
  
  rds_subnet_1_cidr   = "10.200.30.0/25"
  rds_subnet_2_cidr   = "10.200.30.128/25"
  
  on_prem_public_ip   = var.on_premise_ip
  project_name        = "VinHealth-Group15"
}