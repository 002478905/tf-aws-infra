# AWS VPC and Subnet Terraform Setup check3

## Project Overview

This Terraform project is designed to create an AWS Virtual Private Cloud (VPC) with multiple public and private subnets across different availability zones. The infrastructure is defined as code using Terraform, making it reusable and scalable for different environments.

## Features

- Creates a VPC with customizable CIDR blocks.
- Provisions three public subnets and three private subnets across three availability zones.
- Each subnet is configurable using variables (CIDR block, availability zone, and name).
- Supports continuous integration (CI) for validating the Terraform configuration using GitHub Actions.

## Prerequisites

Before you can use this project, you need to have the following installed:

1. [Terraform](https://www.terraform.io/downloads.html)
2. [AWS CLI](https://aws.amazon.com/cli/) configured with credentials.
3. A valid AWS account.

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```
