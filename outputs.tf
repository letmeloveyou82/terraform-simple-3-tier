##########################
# 1단계: VPC + Subnet + IGW + NAT Gateway + Routing
##########################

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_app_subnet_id" {
  value = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  value = aws_subnet.private_db.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

##########################
# 2단계: Web Tier (Security Group + EC2)
##########################

output "web_instance_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_instance_id" {
  description = "Web EC2 instance ID"
  value       = aws_instance.web.id
}

##########################
# 3단계: App Tier (Security Group + EC2)
##########################
output "app_instance_private_ip" {
  value = aws_instance.app.private_ip
}

##########################
# 4단계: DB Tier (Security Group + DB Subnet Group)
##########################
output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}
