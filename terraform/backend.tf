// Terraform backend configuration placeholder
// Configure remote backend (e.g., s3) here

# Uncomment and configure for remote state
# terraform {
#   backend "s3" {
#     bucket         = "my-terraform-state"
#     key            = "api-gateway/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }