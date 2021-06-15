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
  monitoring             = true
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  tags = {
    Name = "terraform-default"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "terraform-demo"
  description = "allow http & ssh"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.43.74.89"]
  }

}

# S3 Bucket to store terraform state
resource "aws_s3_bucket" "state-bucket" {
  bucket = "terraform-state-sk"
  acl    = "private"
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true

  tags = {
    Name        = "State bucket"
    Environment = "Dev"
  }
}

# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "terraform-state-sk"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

# Block Public access for S3 Bucket
#resource "aws_s3_bucket_public_access_block" "terraform-state" {
#    bucket = aws_s3_bucket.terraform-state.id
#    block_public_acls = true
#    block_public_policy = true
#    ignore_public_acls = true
#    restrict_public_buckets = true
#}

#}


# S3 Bucket to host Static Website
resource "aws_s3_bucket" "website" {
  bucket = "s3-website-test.hashicorp.com"
  acl    = "public-read"
  policy = file("policy.json")
  log_bucket = "website-log-sk"
  
  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

# S3 Bucket to store logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "website-log-sk"
  acl    = "log-delivery-write"
}

# KMS Encryption Key
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

# Server Side Encryption for S3 Bucket
resource "aws_s3_bucket" "state-bucket" {
  bucket = "terraform-state-sk"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}


# Create ECR image repository
resource "aws_ecr_repository" "devsecops" {
  name = "devsecops"
}

output "devsecops-repository URL" {
  value = "${aws_ecr_repository.devsecops.repository_url}"
}

# docker built -t https://xxxxxxxx.us-east-1.amazonaws.com/jenkins:1 .
# `aws ecr get-login`
# docker push https://xxxxxxxx.us-east-1.amazonaws.com/jenkins:1 













# Enable AWS Shield to protect EIP against "DDoS" attack
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_shield_protection" "example" {
  name         = "example"
  resource_arn = "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:eip-allocation/${aws_eip.example.id}"

  tags = {
    Environment = "Dev"
  }
}