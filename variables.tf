# =============================================================================
# Variables
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy the cat site into"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair to create"
  type        = string
  default     = "catsite-key"
}

variable "private_key_filename" {
  description = "Local filename where the generated private key will be saved"
  type        = string
  default     = "catsite-key.pem"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "catsite-sg"
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH in. Lock this to your IP in production e.g. [\"1.2.3.4/32\"]"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_allowed_cidrs" {
  description = "CIDR blocks allowed to reach port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_size_gb" {
  description = "Size of the root EBS volume in GB (AL2023 requires >= 30GB)"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "EBS volume type for the root device"
  type        = string
  default     = "gp3"
}

variable "container_name" {
  description = "Name given to the running Docker container on the instance"
  type        = string
  default     = "catsite"
}

variable "container_image_tag" {
  description = "Tag applied to the locally built Docker image"
  type        = string
  default     = "catsite:latest"
}

variable "app_port" {
  description = "Host port the container is mapped to (and the port nginx listens on)"
  type        = number
  default     = 80
}

  variable "ssh_port" {
  description = "Host port the ssh line is mapped to (and the port nginx listens on)"
  type        = number
  default     = 22
}

variable "instance_tag_name" {
  description = "Value of the Name tag on the EC2 instance"
  type        = string
  default     = "catsite"
}
