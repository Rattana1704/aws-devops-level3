variable "ec2_name" {
  type        = string
  description = "Name of the EC2 server"
}

variable "ec2_type" {
  type        = string
  description = "EC2 instance type"
}

variable "keypair" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "ami_id" {
  type        = string
  description = "Amazon Linux 2023 x86_64 AMI ID"
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID"
}

variable "main_sg_id" {
  type        = string
  description = "Security group ID"
}
