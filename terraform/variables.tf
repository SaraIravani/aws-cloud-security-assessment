variable "aws_region" {
  description = "AWS region for the security assessment"
  type        = string
  default     = "ca-central-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "cloudnova-security-assessment"
}
