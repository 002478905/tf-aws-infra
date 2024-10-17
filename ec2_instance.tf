# Define the Security Group for your EC2 instance
resource "aws_security_group" "app_security_group" {
  vpc_id = aws_vpc.csye6225_vpc.id

  name        = "application security group"
  description = "Allow inbound traffic for web app"

  # SSH Access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Access
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application-specific port (replace 8080 with your app's port)
  ingress {
    description = "Allow Application Traffic"
    from_port   = var.app_port # Use the variable
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_security_group"
  }
}

# Create EC2 Instance
resource "aws_instance" "web_app_instance" {
  ami                    = "ami-037a200849f9c67d5" # Replace with your custom AMI ID
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.public_subnet_1.id              # Place the instance in one of your public subnets
  vpc_security_group_ids = [aws_security_group.app_security_group.id] # Attach the security group

  # Disable protection against accidental termination
  disable_api_termination = false

  # Root volume settings
  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "web_app_instance"
  }
}
