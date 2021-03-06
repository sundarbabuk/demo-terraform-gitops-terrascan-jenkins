# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-state-sk"
    key    = "terraform-Iac.tfstate"
    region = "us-east-1"
  }
}

# Use AWS Terraform provider
provider "aws" {
  region = "us-east-1"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type
  ebs_optimized          = true
  monitoring             = true
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tags = {
    Name = "IaC-demo"
  }
}

# Encrypt EBS Volume
resource "aws_ebs_encryption_by_default" "example" {
  enabled = true
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "Iac-demo-sg"
  description = "Allow inbound web traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["110.173.228.255/32"]
  }

  ingress {
    from_port   = 44
    to_port     = 44
    protocol    = "tcp"
    cidr_blocks = ["110.173.228.255/32"]
  }

}
