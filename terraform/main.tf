// Terraform main configuration placeholder
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda Execution Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda Function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambda/hello"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "hello" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-hello"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["GET", "OPTIONS"]
    allow_origins     = ["*"]
    max_age           = 86400
  }
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = var.environment
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "hello" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.hello.invoke_arn
}

resource "aws_apigatewayv2_route" "hello" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /hello"
  target             = "integrations/${aws_apigatewayv2_integration.hello.id}"
  authorization_type = "AWS_IAM"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# Optional Custom Domain for HTTP API
resource "aws_apigatewayv2_domain_name" "custom" {
  count       = var.enable_custom_domain ? 1 : 0
  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "custom" {
  count           = var.enable_custom_domain ? 1 : 0
  api_id          = aws_apigatewayv2_api.main.id
  domain_name     = aws_apigatewayv2_domain_name.custom[0].domain_name
  stage           = aws_apigatewayv2_stage.main.name
  api_mapping_key = var.custom_domain_base_path
}

resource "aws_route53_record" "custom_domain" {
  count   = var.enable_custom_domain && var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.custom_domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

