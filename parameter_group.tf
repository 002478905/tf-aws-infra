resource "aws_db_parameter_group" "parameter-group" {
  name   = "rds-pg-un"
  family = var.family

  parameter {
    name  = "rds.force_ssl"
    value = "0"
     apply_method = "immediate"
  }
}