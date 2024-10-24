# DB Security Group
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.csye6225_vpc.id

  # Allow traffic from EC2 instance security group on port 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id] # Only allow traffic from app security group
  }

  # Allow all outbound traffic
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

# Remove the following redundant block:
# resource "aws_security_group_rule" "allow_app_to_db" {
#   type                     = "ingress"
#   from_port                = 5432
#   to_port                  = 5432
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.db_security_group.id  # RDS DB Security Group
#   source_security_group_id = aws_security_group.app_security_group.id # App Security Group
# }
