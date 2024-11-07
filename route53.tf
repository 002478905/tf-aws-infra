# resource "aws_route53_record" "app" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "dev"  # or "demo" as needed
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.web_app_instance.public_ip]  # Link to EC2 instance

#   depends_on = [aws_instance.web_app_instance]
# }
# resource "aws_route53_zone" "main" {
#   name = "pankhurigupta.me"  # Replace with your actual domain
# }

# Hosted zone configuration for dev.pankhurigupta.me
# Use data source to fetch the existing hosted zone by name
data "aws_route53_zone" "dev_zone" {
  name         = "dev.pankhurigupta.me" # The existing hosted zone for dev.pankhurigupta.me
  private_zone = false                  # Set to true if it's a private hosted zone
}

# Create an A record for dev.pankhurigupta.me in the existing hosted zone
# resource "aws_route53_record" "app" {
#   zone_id = data.aws_route53_zone.dev_zone.zone_id # Reference the existing zone by ID
#   name    = ""                                     # Root record for dev.pankhurigupta.me
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.web_app_instance.public_ip] # Link to EC2 instance's public IP

#   depends_on = [aws_instance.web_app_instance]
# }

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.dev_zone.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }
}