variable "cidr" {
  type = string
  #default = "10.0.0.0/16"
  description = "value"
}
# Public Subnet Variables
variable "public_subnet_1_cidr" {
  type        = string
  description = "CIDR block for Public Subnet 1"
}

variable "public_subnet_1_az" {
  type        = string
  description = "Availability Zone for Public Subnet 1"
}

variable "public_subnet_1_name" {
  type        = string
  description = "Name for Public Subnet 1"
}

variable "public_subnet_2_cidr" {
  type        = string
  description = "CIDR block for Public Subnet 2"
}

variable "public_subnet_2_az" {
  type        = string
  description = "Availability Zone for Public Subnet 2"
}

variable "public_subnet_2_name" {
  type        = string
  description = "Name for Public Subnet 2"
}

variable "public_subnet_3_cidr" {
  type        = string
  description = "CIDR block for Public Subnet 3"
}

variable "public_subnet_3_az" {
  type        = string
  description = "Availability Zone for Public Subnet 3"
}

variable "public_subnet_3_name" {
  type        = string
  description = "Name for Public Subnet 3"
}

# Private Subnet Variables
variable "private_subnet_1_cidr" {
  type        = string
  description = "CIDR block for Private Subnet 1"
}

variable "private_subnet_1_az" {
  type        = string
  description = "Availability Zone for Private Subnet 1"
}

variable "private_subnet_1_name" {
  type        = string
  description = "Name for Private Subnet 1"
}

variable "private_subnet_2_cidr" {
  type        = string
  description = "CIDR block for Private Subnet 2"
}

variable "private_subnet_2_az" {
  type        = string
  description = "Availability Zone for Private Subnet 2"
}

variable "private_subnet_2_name" {
  type        = string
  description = "Name for Private Subnet 2"
}

variable "private_subnet_3_cidr" {
  type        = string
  description = "CIDR block for Private Subnet 3"
}

variable "private_subnet_3_az" {
  type        = string
  description = "Availability Zone for Private Subnet 3"
}

variable "private_subnet_3_name" {
  type        = string
  description = "Name for Private Subnet 3"
}
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Default region
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "dev" # Default profile
}
