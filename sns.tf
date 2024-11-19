
resource "aws_sns_topic" "user_signup_topic" {
  name = "user_signup_topic"
}

resource "aws_sns_topic_subscription" "user_verification_subscription" {
  topic_arn = aws_sns_topic.user_signup_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.user_verification_function.arn
}


# resource "aws_sns_topic" "user_signup_topic" {
#   name = "user-signup-topic"
# }
