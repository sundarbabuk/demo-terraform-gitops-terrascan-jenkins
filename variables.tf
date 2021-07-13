variable "instance_count" {
  default = 1
}

variable "key_name" {
  description = "Private key name to use with instance"
  default     = "terraform"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t3.micro"
}

variable "ami" {
  description = "Base AMI to launch the instances"

  # Grafana AMI Certified by Bitnami
  default = "ami-0a90ed50c0366f4b4"
}
