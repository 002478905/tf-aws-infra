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
  name = "CloudWatchLogsPolicy"
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
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        # "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.arn }/*"
        "Resource" : "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.s3_key.arn
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

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },

    ]
  })
}

resource "aws_iam_policy" "lambda_rds_policy" {
  name = "lambda-rds-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.user_signup_topic.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_role_policy_attachment" "sns_publish" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "sns_publish" {
  name = "sns_publish_policy"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sns:Publish",
        ]
        Effect   = "Allow"
        Resource = aws_sns_topic.user_signup_topic.arn
      },
    ]
  })
}
resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "lambda_execution_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish",
          "sns:Subscribe"
        ]
        Resource = aws_sns_topic.user_signup_topic.arn
      },
      {
        Effect = "Allow"
        Action = [
          "rds:*",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate"
        ]
        Resource = "*"
      },
      {

        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      #  {
      #     Effect= "Allow",
      #     Action= "secretsmanager:GetSecretValue",
      #     Resource= "arn:aws:secretsmanager:*:557690620867:secret:lambda-credentials*"
      #  },
    ]
  })
}

# KMS Permissions Policy for EC2
# resource "aws_iam_policy" "kms_permissions_policy" {
#   name        = "kms-permissions-policy"
#   description = "Policy to allow EC2 instances to interact with KMS keys"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         "Principal": {
#         "AWS": "arn:aws:iam::${var.dev_account_id}:role/ec2-cloudwatch-role"
#       },


#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         Resource = [
#           aws_kms_key.ec2_key.arn,
#           aws_kms_key.rds_key.arn,
#           aws_kms_key.s3_key.arn,
#           aws_kms_key.secrets_key.arn
#         ]
#       }
#     ]
#   })
# }

# Attach KMS Permissions Policy to EC2 Role
# resource "aws_iam_role_policy_attachment" "attach_kms_permissions" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = aws_kms_key.kms_key.arn
# }

# resource "aws_iam_policy" "kms_all_access" {

#   name        = "kms-all-access-policy"
#   description = "Full access to KMS keys for encryption, decryption, and management"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         #    "Principal": {
#         # "AWS": "arn:aws:iam::${var.dev_account_id}:role/ec2-cloudwatch-role"
#       #},

#         Action = [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey",
#           "kms:CreateKey",
#           "kms:UpdateKeyDescription",
#           "kms:ListKeys",
#           "kms:ListAliases",
#           "kms:GetKeyPolicy",
#           "kms:PutKeyPolicy",
#           "kms:ScheduleKeyDeletion",
#           "kms:CancelKeyDeletion",
#           "kms:TagResource",
#           "kms:UntagResource"
#         ],
#         Resource = [
#           aws_kms_key.ec2_key.arn,
#           aws_kms_key.rds_key.arn,
#           aws_kms_key.s3_key.arn,
#           aws_kms_key.secrets_key.arn
#         ]
#       }
#     ]
#   })
# }


resource "aws_kms_key" "kms_key" {
  description             = "Symmetric customer-managed KMS key for EBS"
  deletion_window_in_days = 10
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${var.demo_account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
      },
      {
        "Sid" : "AllowLambdaAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.dev_account_id}:role/lambda-execution-role"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      }
    ] }
  )
}

# resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = aws_iam_policy.secrets_manager_access.arn
# }
# resource "aws_iam_policy" "lambda_secrets_access" {
#   name        = "LambdaSecretsAccess"
#   description = "Allow Lambda to access Secrets Manager"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = "secretsmanager:GetSecretValue",
#         Resource = aws_secretsmanager_secret.email_credentials.arn
#       }
#     ]
#   })
# }
resource "aws_iam_policy" "lambda_secrets_manager_access" {
  name        = "lambda_secrets_manager_access"
  path        = "/"
  description = "IAM policy for Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.db_password.arn,
          aws_secretsmanager_secret.sendgrid_api_key.arn,
        aws_secretsmanager_secret.domain_name.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.secrets_key.arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_access" {
  policy_arn = aws_iam_policy.lambda_secrets_manager_access.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_role_policy" "my_secrets_manager_access_for_ec2" {
  name = "my_secrets_manager_and_kms_access"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "allowmyec2instancetoaccesssecretsmanager"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_password.arn
        ]
      },
      {
        Sid    = "allowmyec2instancetoaccesskms"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "my_kms_access_policy" {
  name = "my_kms_access_policy"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.ec2_key.arn,
          aws_kms_key.s3_key.arn,
          aws_kms_key.rds_key.arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy" "my_rds_access_policy" {
  name = "my_rds_access_policy"
  role = aws_iam_role.ec2_instance_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-db:connect"
        ]
        Resource = aws_db_instance.rds_instance.arn
      }
    ]
  })
}
resource "random_id" "secret_suffix" {
  byte_length = 8
}
resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  #  name        = "sendgrid-api-key-${random_id.secret_suffix.hex}"
  name        = "sendgrid-api-key"
  description = "SendGrid API Key for email service"
  kms_key_id  = aws_kms_key.secrets_key.arn

}
resource "aws_secretsmanager_secret" "domain_name" {
  #  name        = "sendgrid-api-key-${random_id.secret_suffix.hex}"
  name        = "domain_name"
  description = "Domain name for email service"
  kms_key_id  = aws_kms_key.secrets_key.arn

}
resource "aws_secretsmanager_secret_version" "sendgrid_api_key" {
  secret_id     = aws_secretsmanager_secret.sendgrid_api_key.name
  secret_string = var.sendgrid_api_key
}
resource "aws_iam_policy" "lambda_secrets_access" {
  name = "lambda_secrets_access"
  # policy = jsonencode({
  #     Version = "2012-10-17",
  #     Statement = [
  #       {
  #         Effect = "Allow",
  #         Action = [
  #           "secretsmanager:GetSecretValue",
  #           "secretsmanager:DescribeSecret"
  #         ],
  #         Resource = [
  #           aws_secretsmanager_secret.sendgrid_api_key.arn,
  #           # aws_secretsmanager_secret.db_password.arn,       
  #         ]
  #       },
  #        {
  #         Effect   = "Allow",
  #         Action   = ["kms:Decrypt","kms:DescribeKey"],

  #         Resource =aws_kms_key.secrets_key.arn
  #       }
  #     ]
  #   })
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_secretsmanager_secret.sendgrid_api_key.arn
      },
      #   {Action = [
      #     "secretsmanager:GetSecretValue"
      #   ]
      #   Effect   = "Allow"
      #   Resource = "arn:aws:secretsmanager:us-east-1:${var.dev_account_id}:secret:${var.user_creation_secret_name}-*"
      # },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:DescribeKey"]
        Resource = aws_kms_key.secrets_key.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_policy_attach" {
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
  role       = aws_iam_role.lambda_execution_role.name
}
resource "aws_iam_role_policy_attachment" "ec2_secrets_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}
# resource "aws_iam_role_policy_attachment" "ec2_secrets_policy_attachment" {
#    role = aws_iam_role.ec2_instance_role.name
#    policy_arn= aws_iam_policy.lambda_execution_policy.arn
# }

# KMS Key Policy for Secret Manager
resource "aws_kms_key_policy" "secret_manager_key_policy" {
  key_id = aws_kms_key.secrets_key.id
  policy = jsonencode({
    "Id" : "key-for-ebs",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.dev_account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}
