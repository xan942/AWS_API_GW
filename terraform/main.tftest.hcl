# Unit tests for API Gateway configuration

# Test 1: API Gateway main resource has correct CORS configuration
run "test_cors_configuration" {
  command = plan

  assert {
    condition     = aws_apigatewayv2_api.main.cors_configuration[0].allow_credentials == false
    error_message = "CORS allow_credentials should be false"
  }

  assert {
    condition     = contains(aws_apigatewayv2_api.main.cors_configuration[0].allow_headers, "*")
    error_message = "CORS allow_headers should include '*'"
  }

  assert {
    condition     = contains(aws_apigatewayv2_api.main.cors_configuration[0].allow_methods, "GET")
    error_message = "CORS allow_methods should include 'GET'"
  }

  assert {
    condition     = contains(aws_apigatewayv2_api.main.cors_configuration[0].allow_methods, "OPTIONS")
    error_message = "CORS allow_methods should include 'OPTIONS'"
  }

  assert {
    condition     = contains(aws_apigatewayv2_api.main.cors_configuration[0].allow_origins, "*")
    error_message = "CORS allow_origins should include '*'"
  }

  assert {
    condition     = aws_apigatewayv2_api.main.cors_configuration[0].max_age == 86400
    error_message = "CORS max_age should be 86400 seconds"
  }
}

# Test 2: API Gateway /hello route enforces AWS_IAM authorization
run "test_hello_route_iam_authorization" {
  command = plan

  assert {
    condition     = aws_apigatewayv2_route.hello.authorization_type == "AWS_IAM"
    error_message = "Hello route should enforce AWS_IAM authorization"
  }

  assert {
    condition     = aws_apigatewayv2_route.hello.route_key == "GET /hello"
    error_message = "Hello route key should be 'GET /hello'"
  }
}

# Test 3: Custom domain name resource is created when enable_custom_domain is true
run "test_custom_domain_created_when_enabled" {
  command = plan

  variables {
    enable_custom_domain  = true
    custom_domain_name    = "api.example.com"
    acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/test-cert-id"
  }

  assert {
    condition     = length(aws_apigatewayv2_domain_name.custom) == 1
    error_message = "Custom domain should be created when enable_custom_domain is true"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.custom[0].domain_name == "api.example.com"
    error_message = "Custom domain name should match the provided value"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].endpoint_type == "REGIONAL"
    error_message = "Custom domain endpoint type should be REGIONAL"
  }

  assert {
    condition     = aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].security_policy == "TLS_1_2"
    error_message = "Custom domain security policy should be TLS_1_2"
  }
}

# Test 3b: Custom domain name resource is NOT created when enable_custom_domain is false
run "test_custom_domain_not_created_when_disabled" {
  command = plan

  variables {
    enable_custom_domain = false
  }

  assert {
    condition     = length(aws_apigatewayv2_domain_name.custom) == 0
    error_message = "Custom domain should NOT be created when enable_custom_domain is false"
  }
}

# Test 4: Route53 alias record is created when enable_custom_domain is true and hosted_zone_id is provided
run "test_route53_record_created_with_hosted_zone" {
  command = plan

  variables {
    enable_custom_domain  = true
    custom_domain_name    = "api.example.com"
    acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/test-cert-id"
    hosted_zone_id        = "Z1234567890ABC"
  }

  assert {
    condition     = length(aws_route53_record.custom_domain) == 1
    error_message = "Route53 record should be created when enable_custom_domain is true and hosted_zone_id is provided"
  }

  assert {
    condition     = aws_route53_record.custom_domain[0].zone_id == "Z1234567890ABC"
    error_message = "Route53 record should use the provided hosted_zone_id"
  }

  assert {
    condition     = aws_route53_record.custom_domain[0].name == "api.example.com"
    error_message = "Route53 record name should match the custom domain name"
  }

  assert {
    condition     = aws_route53_record.custom_domain[0].type == "A"
    error_message = "Route53 record type should be 'A'"
  }

  assert {
    condition     = aws_route53_record.custom_domain[0].alias[0].evaluate_target_health == false
    error_message = "Route53 alias should not evaluate target health"
  }
}

# Test 4b: Route53 alias record is NOT created when hosted_zone_id is empty
run "test_route53_record_not_created_without_hosted_zone" {
  command = plan

  variables {
    enable_custom_domain  = true
    custom_domain_name    = "api.example.com"
    acm_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/test-cert-id"
    hosted_zone_id        = ""
  }

  assert {
    condition     = length(aws_route53_record.custom_domain) == 0
    error_message = "Route53 record should NOT be created when hosted_zone_id is empty"
  }
}

# Test 4c: Route53 alias record is NOT created when enable_custom_domain is false
run "test_route53_record_not_created_when_custom_domain_disabled" {
  command = plan

  variables {
    enable_custom_domain = false
    hosted_zone_id       = "Z1234567890ABC"
  }

  assert {
    condition     = length(aws_route53_record.custom_domain) == 0
    error_message = "Route53 record should NOT be created when enable_custom_domain is false"
  }
}

# Test 5: API Gateway mapping is created with correct base path
run "test_api_mapping_with_base_path" {
  command = plan

  variables {
    enable_custom_domain      = true
    custom_domain_name        = "api.example.com"
    acm_certificate_arn       = "arn:aws:acm:us-east-1:123456789012:certificate/test-cert-id"
    custom_domain_base_path   = "v1"
  }

  assert {
    condition     = length(aws_apigatewayv2_api_mapping.custom) == 1
    error_message = "API mapping should be created when enable_custom_domain is true"
  }

  assert {
    condition     = aws_apigatewayv2_api_mapping.custom[0].api_mapping_key == "v1"
    error_message = "API mapping should use the provided base path"
  }

  assert {
    condition     = aws_apigatewayv2_api_mapping.custom[0].domain_name == "api.example.com"
    error_message = "API mapping should reference the custom domain name"
  }
}

# Test 5b: API Gateway mapping with empty base path (root path)
run "test_api_mapping_with_empty_base_path" {
  command = plan

  variables {
    enable_custom_domain      = true
    custom_domain_name        = "api.example.com"
    acm_certificate_arn       = "arn:aws:acm:us-east-1:123456789012:certificate/test-cert-id"
    custom_domain_base_path   = ""
  }

  assert {
    condition     = length(aws_apigatewayv2_api_mapping.custom) == 1
    error_message = "API mapping should be created when enable_custom_domain is true"
  }

  assert {
    condition     = aws_apigatewayv2_api_mapping.custom[0].api_mapping_key == ""
    error_message = "API mapping should have empty base path for root mapping"
  }
}

# Test 5c: API Gateway mapping is NOT created when enable_custom_domain is false
run "test_api_mapping_not_created_when_disabled" {
  command = plan

  variables {
    enable_custom_domain = false
  }

  assert {
    condition     = length(aws_apigatewayv2_api_mapping.custom) == 0
    error_message = "API mapping should NOT be created when enable_custom_domain is false"
  }
}
