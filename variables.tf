##########################
# 1단계: VPC + Subnet + IGW + NAT Gateway + Routing
##########################

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag prefix for resources"
  type        = string
}

variable "az" {
  description = "Availability Zone"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_app_subnet_cidr" {
  description = "CIDR block for the private app subnet"
  type        = string
}

variable "private_db_subnet_cidr" {
  description = "CIDR block for the private DB subnet"
  type        = string
}

##########################
# 2단계: Web Tier (Security Group + EC2)
##########################

variable "web_ami" {
  description = "AMI ID for the web EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key name to access EC2 instances"
  type        = string
}

##########################
# 3단계: App Tier (Security Group + EC2)
##########################
variable "app_ami" {
  description = "AMI ID for the App EC2"
  type        = string
}

##########################
# 4단계: DB Tier (Security Group + DB Subnet Group)
##########################
variable "db_username" {
  description = "DB admin username"
  type        = string
}

variable "db_password" {
  description = "DB admin password"
  type        = string
  sensitive   = true
}
