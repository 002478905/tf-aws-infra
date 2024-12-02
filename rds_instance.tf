# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "webapp"
  username               = "postgres"
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Attach the parameter group here
  parameter_group_name = aws_db_parameter_group.parameter-group.name
  storage_encrypted    = true
  kms_key_id           = aws_kms_key.rds_key.arn
  tags = {
    Name = "csye6225-db"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "private_subnet_group" {
  name        = "private-subnet-group-un"
  description = "Subnet group for RDS instance"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id,
  ]

  tags = {
    Name = "private-subnet-group"
  }
}
