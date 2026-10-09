variable "region" {
  description = "AWS_region"
  type        = string

}

variable "instance_type" {
  description = "Instance type"
  type        = string

}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (use your IP/32)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_key_path" {
  description = "Local path to the SSH private key that matches key_name"
  type        = string

}
