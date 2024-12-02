resource "random_id" "suffix" {
  byte_length = 8
}

# Generate a random password
resource "random_password" "db_password" {
  length           = 16
  special          = false
  upper            = true
  lower            = true
  numeric          = true
  override_special = ""
}

# Store the database password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password-${random_id.suffix.hex}"
  #name        = var.secrets_manager_name
  description = "Database password for RDS instance"
  kms_key_id  = aws_kms_key.secrets_key.arn
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    POSTGRES_PASSWORD = random_password.db_password.result
    #   SENDGRID_API_KEY     = var.sendgrid_api_key
    # VERIFICATION_BASE_URL = var.verification_base_url
    # SNS_TOPIC_ARN        = aws_sns_topic.user_signup_topic.arn
  })
}
resource "aws_secretsmanager_secret_version" "lambda_credentials" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    POSTGRES_PASSWORD     = random_password.db_password.result
    SENDGRID_API_KEY      = var.sendgrid_api_key
    VERIFICATION_BASE_URL = var.verification_base_url
    SNS_TOPIC_ARN         = aws_sns_topic.user_signup_topic.arn
  })
}
resource "aws_secretsmanager_secret_version" "domain_version" {
  secret_id     = aws_secretsmanager_secret.domain_name.id
  secret_string = jsonencode({ DOMAIN = "${var.env}${var.verification_base_url}" })
}

# Store email credentials in Secrets Manager
# resource "aws_secretsmanager_secret" "email_credentials" {
#   name        = "email-credentials-${random_id.suffix.hex}"
#   description = "Credentials for Email Service"
#   kms_key_id  = aws_kms_key.secrets_key.arn
# }

# resource "aws_secretsmanager_secret_version" "email_credentials" {
#   secret_id     = aws_secretsmanager_secret.email_credentials.id
#   secret_string = jsonencode({
#     username = var.email_username
#     password = var.email_password
#   })
# }


