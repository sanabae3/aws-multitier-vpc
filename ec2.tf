# Find latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

# Simple user_data: update OS and install CloudWatch agent stub
locals {
  bastion_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    # Install CloudWatch Agent (Amazon Linux 2)
    yum install -y amazon-cloudwatch-agent
    # Here you would drop your /opt/aws/amazon-cloudwatch-agent/bin/config.json
    # and start the agent, e.g.:
    # /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    #   -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/config.json -s
  EOF
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = local.bastion_user_data

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-bastion"
    Role = "bastion"
  })
}
