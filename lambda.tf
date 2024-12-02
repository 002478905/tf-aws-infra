resource "aws_lambda_function" "user_verification_function" {
  function_name    = "user-verification-function"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.lambda_execution_role.arn
  source_code_hash = filebase64sha256("${path.module}/mail.zip")
  filename         = "${path.module}/mail.zip"

  # environment {
  #   variables = {

  #     SENDGRID_API_KEY      = var.sendgrid_api_key
  #     VERIFICATION_BASE_URL = "${var.env}${var.verification_base_url}"
  #     SNS_TOPIC_ARN         = aws_sns_topic.user_signup_topic.arn
  #     // SENDGRID_API_KEY = var.sendgrid_api_key
  #     //VERIFICATION_BASE_URL = "https://yourdomain.com"  // Add this line
  #   }
  # }
  environment {
    variables = {

      # SENDGRID_API_KEY      = var.sendgrid_api_key
      # VERIFICATION_BASE_URL = "${var.env}${var.verification_base_url}"
      # SNS_TOPIC_ARN         = aws_sns_topic.user_signup_topic.arn
      // SENDGRID_API_KEY = var.sendgrid_api_key
      //VERIFICATION_BASE_URL = "https://yourdomain.com"  // Add this line
    }
  }



}

# resource "aws_sns_topic" "user_signup_topic" {
#   name = "user-signup-topic"
# }
