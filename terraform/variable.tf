variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-3"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-00ffe463659a905fd"
}

variable "igw_id" {
  description = "Existing Internet Gateway ID"
  type        = string
  default     = "igw-0ab67e09d24810be0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Public key content for EC2 key pair"
  type        = string
  sensitive   = true
}

variable "subnet_cidr" {
  description = "CIDR block for Ridwan's Public Subnet"
  type        = string
  default     = "10.0.21.0/24"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "tesa-lab-key"
}