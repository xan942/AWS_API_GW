// Terraform variables placeholder

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "my-xAPI"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "enable_custom_domain" {
  description = "Enable custom domain for the API"
  type        = bool
  default     = false
}

variable "custom_domain_name" {
  description = "Custom domain name (e.g., api.example.com)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the custom domain (in the same region as the API)"
  type        = string
  default     = ""
}

variable "custom_domain_base_path" {
  description = "Base path for API mapping (empty for root)"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Route53 Hosted Zone ID for your domain (to create an alias record)"
  type        = string
  default     = ""
}

