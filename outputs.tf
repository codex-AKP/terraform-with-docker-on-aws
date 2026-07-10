# =============================================================================
# Outputs
# =============================================================================

output "ssh_command" {
  description = "SSH command to log into the EC2 instance"
  value       = "ssh -i ${var.private_key_filename} ec2-user@${aws_instance.catsite.public_ip}"
}

output "static_website_url" {
  description = "URL of the cat static website served from inside the Docker container"
  value       = "http://${aws_instance.catsite.public_dns}"
}

output "docker_container_url" {
  description = "Direct URL to the running Docker container via the instance public IP"
  value       = "http://${aws_instance.catsite.public_ip}:${var.app_port}"
}

output "instance_public_ip" {
  description = "Raw public IP address of the EC2 instance"
  value       = aws_instance.catsite.public_ip
}

output "instance_public_dns" {
  description = "Raw public DNS name of the EC2 instance"
  value       = aws_instance.catsite.public_dns
}
