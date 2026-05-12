# ==================================================
# 1. SSH KEY PAIR (Chìa khóa để Ansible truy cập)
# ==================================================
resource "aws_key_pair" "deployer" {
  key_name   = "vinhealth-key-pair"
  public_key = file("./vinhealth_key.pub") # Terraform sẽ đọc file này ở thư mục gốc
}

# ==================================================
# 2. SECURITY GROUPS (Zero Trust Firewall)
# ==================================================
resource "aws_security_group" "ec2_sg" {
  name        = "vinhealth-ec2-sg"
  description = "Cho phep truy cap Web va SSH tu mang noi bo"
  vpc_id      = module.vinhealth_vpc.vpc_id

  # Cổng 80/443 cho Web
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cổng 22 cho Ansible (SSH)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Chỉ cho phép SSH từ mạng nội bộ EVE-NG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "VinHealth-EC2-SG" }
}

# ==================================================
# 3. MÁY CHỦ WEB EC2 (Dành cho Ansible cấu hình)
# ==================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web_ehr" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name 
  
  # 1. Chuyển nhà ra Public Subnet (Cloud DMZ)
  subnet_id                   = module.vinhealth_vpc.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  
  # 2. Cấp 1 IP Public thật để bạn dùng trình duyệt truy cập
  associate_public_ip_address = true

  # 3. Code cài Nginx, tạo Web và tự động lấy chứng chỉ HTTPS miễn phí
  user_data = <<-EOF
              #!/bin/bash
              # 1. Cài đặt các gói cần thiết
              apt-get update -y
              apt-get install nginx certbot python3-certbot-nginx -y

              # 2. Tạo trang Web Patient Portal
              echo "<div style='text-align:center; margin-top:50px;'>
                      <h1>VINHEALTH EHR PATIENT PORTAL</h1>
                      <p>He thong dang chay tren Vung DMZ (AWS Public Cloud)</p>
                      <p style='color:green;'>Trang web da duoc bao mat bang HTTPS/SSL</p>
                    </div>" > /var/www/html/index.html

              # 3. Lấy IP Public của chính máy ảo này bằng lệnh curl
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
              
              # 4. Tạo tên miền miễn phí với nip.io
              DOMAIN="$PUBLIC_IP.nip.io"

              # 5. Cấu hình Nginx nhận diện tên miền này
              sed -i "s/server_name _;/server_name $DOMAIN;/g" /etc/nginx/sites-available/default
              systemctl restart nginx

              # 6. Dùng Certbot tự động xin chứng chỉ HTTPS từ Let's Encrypt (Bỏ qua prompt)
              certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect

              # Khởi động lại dịch vụ
              systemctl restart nginx
              EOF

  tags = { Name = "VinHealth-EHR-Web-Server-DMZ" }
}
# ==================================================
# 4. KHO LƯU TRỮ S3 (DICOM)
# ==================================================
resource "random_id" "s3_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "dicom_storage" {
  bucket = "vinhealth-dicom-storage-${random_id.s3_id.hex}"
  tags   = { Name = "VinHealth-DICOM-Archive" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dicom_crypto" {
  bucket = aws_s3_bucket.dicom_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==================================================
# 5. RDS DATABASE (PostgreSQL)
# ==================================================
resource "aws_security_group" "rds_sg" {
  name        = "vinhealth-rds-sg"
  vpc_id      = module.vinhealth_vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  db_name              = "vinhealth_ehr"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  username             = "admin_user"
  password             = "VinHealth2026!"
  
  db_subnet_group_name = module.vinhealth_vpc.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  multi_az             = true 
  skip_final_snapshot  = true 

  tags = { Name = "VinHealth-EHR-Database" }
}