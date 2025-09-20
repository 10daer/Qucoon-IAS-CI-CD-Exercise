# Data sources for existing resources
data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_internet_gateway" "existing" {
  internet_gateway_id = var.igw_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-22.04-lts-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# # Create subnet
# resource "aws_subnet" "public" {
#   vpc_id                  = data.aws_vpc.existing.id
#   cidr_block              = var.subnet_cidr
#   availability_zone       = data.aws_availability_zones.available.names[0]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "tesa-lab-Ridwan-public-subnet"
#     Type = "Public"
#   }
# }

# # Create route table for public subnet
# resource "aws_route_table" "public" {
#   vpc_id = data.aws_vpc.existing.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = data.aws_internet_gateway.existing.id
#   }

#   tags = {
#     Name = "tesa-lab-Ridwan-public-rt"
#   }
# }

# # Associate route table with subnet
# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }

# # Security Group for web server
# resource "aws_security_group" "web_server" {
#   name        = "tesa-lab-Ridwan-web-server-sg"
#   description = "Security group for Ridwan's web server"
#   vpc_id      = data.aws_vpc.existing.id

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "HTTPS"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Restrict this to my IP for security
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "tesa-lab-Ridwan-web-server-sg"
#   }
# }

# # Create EC2 key pair
# resource "aws_key_pair" "web_server_key" {
#   key_name   = var.key_pair_name
#   public_key = var.public_key
# }

# # IAM role for EC2 instance
# resource "aws_iam_role" "ec2_role" {
#   name = "tesa-lab-Ridwan-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # IAM policy for EC2 instance (for GitHub Actions deployment)
# resource "aws_iam_role_policy" "ec2_policy" {
#   name = "tesa-lab-Ridwan-ec2-policy"
#   role = aws_iam_role.ec2_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # IAM instance profile
# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "tesa-lab-Ridwan-ec2-profile"
#   role = aws_iam_role.ec2_role.name
# }

# # User data script
# locals {
#   user_data = base64encode(<<-EOF
# #!/bin/bash
# apt-get update
# apt-get install -y nginx git awscli

# # Configure nginx
# systemctl start nginx
# systemctl enable nginx

# # Create web directory
# mkdir -p /var/www/html/website
# chown -R www-data:www-data /var/www/html/website

# # Create nginx configuration
# cat > /etc/nginx/sites-available/website << 'EOL'
# server {
#     listen 80;
#     server_name _;
#     root /var/www/html/website;
#     index index.html index.htm;

#     location / {
#         try_files $uri $uri/ =404;
#     }
# }
# EOL

# # Enable the site
# ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/
# rm /etc/nginx/sites-enabled/default
# systemctl reload nginx

# # Create initial index.html
# cat > /var/www/html/website/index.html << 'EOL'
# <!DOCTYPE html>
# <html>
# <head><title>Tesa Lab</title></head>
# <body><h1>Server Ready for Deployment</h1></body>
# </html>
# EOL

# chown -R www-data:www-data /var/www/html/website

# # Setup deploy user
# useradd -m -s /bin/bash deploy
# usermod -aG www-data deploy
# mkdir -p /home/deploy/.ssh
# chown deploy:deploy /home/deploy/.ssh
# chmod 700 /home/deploy/.ssh

# # Allow deploy user to restart nginx
# echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx" >> /etc/sudoers
# echo "deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx" >> /etc/sudoers
# EOF
#   )
# }

# # EC2 Instance
# resource "aws_instance" "web_server" {
#   ami                     = data.aws_ami.ubuntu.id
#   instance_type           = "t3.micro"
#   key_name               = aws_key_pair.web_server_key.key_name
#   vpc_security_group_ids = [aws_security_group.web_server.id]
#   subnet_id              = aws_subnet.public.id
#   iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
#   user_data              = local.user_data

#   root_block_device {
#     volume_type = "gp3"
#     volume_size = 10
#     encrypted   = true
#   }

#   tags = {
#     Name = "tesa-lab-Ridwan-web-server"
#     Type = "WebServer"
#   }
# }

# # Elastic IP for the instance
# resource "aws_eip" "web_server_eip" {
#   instance = aws_instance.web_server.id
#   domain   = "vpc"

#   tags = {
#     Name = "tesa-lab-Ridwan-web-server-eip"
#   }

#   depends_on = [aws_internet_gateway.existing]
# }

