# resource "aws_kms_key" "kms_key" {
#   description             = "Symmetric customer-managed KMS key for EBS"
#   deletion_window_in_days = 10
#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [{
#       "Sid" : "Enable IAM User Permissions",
#       "Effect" : "Allow",
#       "Principal" : {
#         "AWS" : "arn:aws:iam::${var.dev_account_id}:root"
#       },
#       "Action" : "kms:*",
#       "Resource" : "*"
#       },
#       {
#         "Sid" : "Allow service-linked role use of the customer managed key",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : [
#             "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
#           ]
#         },
#         "Action" : [
#           "kms:Encrypt",
#           "kms:Decrypt",
#           "kms:ReEncrypt*",
#           "kms:GenerateDataKey*",
#           "kms:DescribeKey"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "Allow attachment of persistent resources",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : [
#             "arn:aws:iam::${var.dev_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
#           ]
#         },
#         "Action" : [
#           "kms:CreateGrant"
#         ],
#         "Resource" : "*",
#         "Condition" : {
#           "Bool" : {
#             "kms:GrantIsForAWSResource" : true
#           }
#         }
#       }
#     ] }
#   )
# }
resource "aws_launch_template" "web_app_lt" {
  name_prefix   = "web-app-lt"
  image_id      = var.custom_ami
  instance_type = "t2.small"

  tags = {
    Name = "web-app-lt" # Add this tag to match the workflow filter
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_security_group.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 25
      volume_type = "gp2"
      encrypted   = true
      #  kms_key_id  = aws_kms_key.ec2_key.arn
      kms_key_id = aws_kms_key.kms_key.arn
    }
  }
  user_data = base64encode(<<-EOF
          #!/bin/bash
          # Install AWS CLI if not already available
          
          sudo apt-get update -y
          sudo apt-get install -y unzip  jq
          
          cd /tmp
          
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          
          unzip awscliv2.zip
          
          sudo ./aws/install
          
          cd ..



          # Retrieve database password from Secrets Manager
          SECRET=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db_password.name} --region ${var.aws_region} --query SecretString --output text)

          DB_PASSWORD=$(echo $SECRET | jq -r .POSTGRES_PASSWORD)

          
          # Create .env file
          mkdir -p /home/csye6225/webapp
          touch /home/csye6225/webapp/.env

          # Write environment variables to .env file
          echo "DB_HOST=${aws_db_instance.rds_instance.address}" >> /home/csye6225/webapp/.env
          echo "DB_USER=${var.rds_username}" >> /home/csye6225/webapp/.env
          echo "DB_PASSWORD=$DB_PASSWORD" >> /home/csye6225/webapp/.env
          echo "DB_DATABASE=${var.rds_db_name}" >> /home/csye6225/webapp/.env
          echo "S3_BUCKET_NAME=${aws_s3_bucket.bucket.bucket}" >> /home/csye6225/webapp/.env
          echo "SNS_TOPIC_ARN=${aws_sns_topic.user_signup_topic.arn}" >> /home/csye6225/webapp/.env
          # Reload the systemd daemon and restart the app service
          sudo systemctl daemon-reload
          sudo systemctl restart app.service

          # Configure and start the CloudWatch agent
          sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
              -a fetch-config \
              -m ec2 \
              -c file:/opt/webapp/cloud-watch-config.json \
              -s
          sudo systemctl enable amazon-cloudwatch-agent
          sudo systemctl start amazon-cloudwatch-agent

          # Enable and start the app service
          sudo systemctl enable app.service
          sudo systemctl start app.service
          EOF
  )


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-app-instance"
    }
  }
}