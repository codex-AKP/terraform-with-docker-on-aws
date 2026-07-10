# =============================================================================
# Cat Site — main.tf
# Provider, key pair, security group, AMI lookup, EC2 instance
# =============================================================================

# -----------------------------------------------------------------------------
# Provider
# -----------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# SSH Key Pair
# Terraform generates an RSA key pair. The private key is written to disk
# so you can SSH straight in after apply.
# -----------------------------------------------------------------------------

resource "tls_private_key" "catsite" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "catsite" {
  key_name   = var.key_name
  public_key = tls_private_key.catsite.public_key_openssh
}

# Saves the private key locally with strict permissions (chmod 600)
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.catsite.private_key_pem
  filename        = "${path.module}/${var.private_key_filename}"
  file_permission = "0400"
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "catsite" {
  name        = var.security_group_name
  description = "HTTP and SSH access for the cat site"

  ingress {
    description = "HTTP - public website"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.http_allowed_cidrs
  }

  ingress {
    description = "SSH - restrict to your IP in production"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# -----------------------------------------------------------------------------
# AMI — latest Amazon Linux 2023 (x86_64, HVM)
# -----------------------------------------------------------------------------

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# EC2 Instance
# user_data bootstraps the instance on first boot:
#   1. Installs Docker
#   2. Writes the Dockerfile and index.html to /opt/catsite/
#   3. Builds the Docker image locally (no external registry needed)
#   4. Runs the container on var.app_port with auto-restart
# -----------------------------------------------------------------------------

resource "aws_instance" "catsite" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.catsite.key_name
  vpc_security_group_ids      = [aws_security_group.catsite.id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    container_name      = var.container_name
    container_image_tag = var.container_image_tag
    app_port            = var.app_port
  }))

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_tag_name
  }
}
