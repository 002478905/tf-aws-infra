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

  user_data = base64encode(<<-EOF
              #!/bin/bash
              
              # Create .env file
              mkdir -p /home/csye6225/webapp
              touch /home/csye6225/webapp/.env

              # Write environment variables to .env file
              echo "DB_HOST=${aws_db_instance.rds_instance.address}" >> /home/csye6225/webapp/.env
              echo "DB_USER=${var.rds_username}" >> /home/csye6225/webapp/.env
              echo "DB_PASSWORD=${var.rds_password}" >> /home/csye6225/webapp/.env
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