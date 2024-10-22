# DB Security Group
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.csye6225_vpc.id

  # Allow only the EC2 instance to connect to the RDS instance on PostgreSQL port (5432)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id] # Only allow traffic from EC2 Security Group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_security_group"
  }
}
