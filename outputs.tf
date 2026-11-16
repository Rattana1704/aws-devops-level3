output "ec2_instance_id" {
  value = aws_instance.devops_school_level3.id
}

output "ec2_public_dns_name" {
  value = aws_instance.devops_school_level3.public_dns
}

output "ec2_public_ip" {
  value = aws_instance.devops_school_level3.public_ip
}
