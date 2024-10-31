# Define IAM Role for EC2 instance with CloudWatch and S3 access
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# CloudWatch Logs Policy
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name   = "CloudWatchLogsPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach CloudWatch Logs Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# CloudWatch Agent Server Policy (AWS Managed Policy)
resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Full Access to CloudWatch Logs (AWS Managed Policy)
resource "aws_iam_role_policy_attachment" "logs_access" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Additional Custom Policy for CloudWatch Log Group Creation and EC2 Metadata Access
resource "aws_iam_policy" "cloudwatch_custom_policy" {
  name        = "ec2-cloudwatch-custom-policy"
  description = "Custom permissions for CloudWatch log creation and EC2 metadata access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the Custom CloudWatch Policy to IAM Role
resource "aws_iam_role_policy_attachment" "custom_cloudwatch_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.cloudwatch_custom_policy.arn
}

# S3 Delete Object Policy
resource "aws_iam_policy" "s3_delete_object_policy" {
  name        = "S3DeleteObjectPolicy"
  description = "Policy to allow deletion of objects in the specified S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

# Attach S3 Delete Object Policy to IAM Role
resource "aws_iam_role_policy_attachment" "s3_delete_object_role_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.s3_delete_object_policy.arn
}

# Define IAM Instance Profile for the EC2 Role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}
