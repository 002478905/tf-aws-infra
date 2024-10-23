# DB Security Group
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.csye6225_vpc.id

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

# Ingress rule to allow traffic from EC2 instance (app_security_group)
resource "aws_security_group_rule" "allow_app_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_security_group.id  # RDS DB Security Group
  source_security_group_id = aws_security_group.app_security_group.id # App Security Group
}
