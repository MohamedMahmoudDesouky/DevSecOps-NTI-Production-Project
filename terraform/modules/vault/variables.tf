variable "project_name" {
  description = "Project name for tagging and resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Vault will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of public subnet IDs for Vault EC2"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access Vault UI/API"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
}
