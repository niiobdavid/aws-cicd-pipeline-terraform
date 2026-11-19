# Amazon Linux 2, to match your scripts (yum, tomcat, /usr/share/tomcat/webapps)
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# AWS's IP range for EC2 Instance Connect, so the console "Connect" button works
data "aws_ec2_managed_prefix_list" "instance_connect" {
  name = "com.amazonaws.${var.aws_region}.ec2-instance-connect"
}

resource "aws_security_group" "webserver" {
  name        = "${var.project_name}-webserver-sg"
  description = "HTTP for the web app, SSH only from EC2 Instance Connect"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_http_cidr]
  }

  ingress {
    description     = "SSH from EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.instance_connect.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.webserver.name
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  associate_public_ip_address = true

  # Installs and starts the CodeDeploy agent on first boot.
  # Tomcat and Apache are installed by your own scripts/install_dependencies.sh during deployment.
  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y ruby wget
    cd /tmp
    wget https://aws-codedeploy-${var.aws_region}.s3.${var.aws_region}.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto
    systemctl enable codedeploy-agent
    systemctl start codedeploy-agent
  EOF

  tags = {
    Name = "${var.project_name}-webserver"
    role = "webserver"
  }

  # The role must exist before the agent starts, or it can't fetch credentials
  depends_on = [
    aws_iam_role_policy.webserver_artifacts,
    aws_iam_role_policy_attachment.webserver_ssm
  ]
}
