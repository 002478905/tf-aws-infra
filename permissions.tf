
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
 # function_name = aws_lambda_function.user_verification_function.arn
  function_name = aws_lambda_function.user_verification_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_signup_topic.arn
}
