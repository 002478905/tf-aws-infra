# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  db_name                = "csye6225"               # Corrected attribute
  username               = "csye6225"
  password               = "strongpassword"
  db_subnet_group_name   = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "csye6225-db"
  }
}
