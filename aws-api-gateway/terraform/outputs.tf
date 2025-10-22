// Terraform outputs placeholder
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "api_url" {
  description = "Full API URL"
  value       = "${aws_apigatewayv2_api.main.api_endpoint}/${var.environment}/hello"
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.hello.function_name
}