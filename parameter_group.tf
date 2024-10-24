resource "aws_db_parameter_group" "parameter-group" {
  name   = "rds-pg"
  family = var.family

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}