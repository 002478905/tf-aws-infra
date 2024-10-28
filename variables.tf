variable "cidr" {
  type        = string
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

variable "custom_ami" {
  description = "ID of the custom AMI to use"
  type        = string
}

variable "app_port" {
  description = "Port where the application runs"
  type        = number
  default     = 8081 # Change this to your application port
}

variable "family" {
  description = "Port where the application runs"
  type        = string

}

# variables.tf

variable "rds_identifier" {
  description = "The RDS instance identifier"
  type        = string
  default     = "csye6225"
}

variable "rds_engine" {
  description = "The database engine for RDS"
  type        = string
  default     = "postgres"
}

variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "The name of the RDS database"
  type        = string
  default     = "webapp"
}

variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
  default     = "root12345"
}
