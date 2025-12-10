resource "aws_route53_zone" "private" {
  name = var.private_domain_name

  vpc {
    vpc_id = aws_vpc.main.id
  }

  comment = "${var.project_name} private hosted zone"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-zone"
  })
}

# Bastion A record (for convenience if you resolve from inside VPC)
resource "aws_route53_record" "bastion" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bastion.${var.private_domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_instance.bastion.private_ip]
}

# Example app record pointing to a private IP (placeholder)
# You can change this to point to ALB, EC2, or RDS endpoint later.
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "app.${var.private_domain_name}"
  type    = "A"
  ttl     = 60
  records = [aws_subnet.private[0].cidr_block == "" ? "10.0.11.10" : "10.0.11.10"]
}
