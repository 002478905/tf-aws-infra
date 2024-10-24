# Define the Security Group for your EC2 instance
resource "aws_security_group" "app_security_group" {
  vpc_id = aws_vpc.csye6225_vpc.id

  name        = "application_security_group"
  description = "Allow inbound traffic for web app"

  # SSH Access (allowing from anywhere, modify based on requirements)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access (Port 80)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # HTTP Access (Port 80)
  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS Access (Port 443)
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application-specific port (Replace 8080 with your application's port, using variable for flexibility)
  ingress {
    description = "Allow Application Traffic"
    from_port   = var.app_port
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
  ami                    = var.custom_ami # Use the custom AMI built by Packer
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

  # User Data to pass RDS details to the EC2 instance for database connection
  # user_data = <<-EOF
  #   #!/bin/bash
  #   echo "DB_HOST=${aws_db_instance.rds_instance.endpoint}" >> /home/ubuntu/.env
  #   echo "DB_USER=postgres" >> /home/ubuntu/.env
  #   echo "DB_PASSWORD=root12345" >> /home/ubuntu/.env
  #   echo "DB_NAME=webapp" >> /home/ubuntu/.env
  #   sudo systemctl restart app  # Restart the app to pick up new environment variables
  # EOF
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update the app.service file with the new database information
              sudo sed -i 's|Environment="DB_HOST=localhost"|Environment="DB_HOST=${aws_db_instance.rds_instance.endpoint}"|g' /etc/systemd/system/app.service
              sudo sed -i 's|Environment="DB_USER=postgres"|Environment="DB_USER=${var.rds_username}"|g' /etc/systemd/system/app.service
              sudo sed -i 's|Environment="DB_PASSWORD=root12345"|Environment="DB_PASSWORD=${var.rds_password}"|g' /etc/systemd/system/app.service
              sudo sed -i 's|Environment="DB_DATABASE=webapp"|Environment="DB_DATABASE=${var.rds_db_name}"|g' /etc/systemd/system/app.service
 
              # Reload systemd to recognize the changes
              sudo systemctl daemon-reload
 
              # Restart your application service
              sudo systemctl restart app.service
              EOF
  )

  # Optional: Add monitoring and instance lifecycle hooks
  monitoring = true

  tags = {
    Name = "web_app_instance"
  }
}
