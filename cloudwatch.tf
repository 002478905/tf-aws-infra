# # cloudwatch.tf

# # Define IAM role for EC2 if not already defined in another file
# resource "aws_iam_role" "ec2_instance_role" {
#   name = "ec2-cloudwatch-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # Attach the managed policy for CloudWatch Agent Server Policy
# resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# # Attach the managed policy for full access to CloudWatch Logs
# resource "aws_iam_role_policy_attachment" "logs_access" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
# }

# # Additional custom policy for creating log groups and streams and EC2 metadata access
# resource "aws_iam_policy" "cloudwatch_custom_policy" {
#   name        = "ec2-cloudwatch-custom-policy"
#   description = "Custom permissions for CloudWatch log creation and EC2 metadata access"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "ec2:DescribeInstances",
#           "ec2:DescribeTags"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Attach the custom policy to the role
# resource "aws_iam_role_policy_attachment" "custom_cloudwatch_policy" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = aws_iam_policy.cloudwatch_custom_policy.arn
# }
