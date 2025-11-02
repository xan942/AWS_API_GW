# AWS API Gateway Project

A basic AWS API Gateway setup with Lambda integration using Terraform.

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform >= 1.0
- Node.js >= 18.x
- Python 3.x (for integration tests)

## Setup

### 1. Configure GitHub Secrets (Required for CI/CD)

Before deploying via GitHub Actions, set up AWS credentials as repository secrets:

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:
   - **Name:** `AWS_ACCESS_KEY_ID`  
     **Value:** Your AWS access key ID
   - **Name:** `AWS_SECRET_ACCESS_KEY`  
     **Value:** Your AWS secret access key

**Important:** These credentials need the following IAM permissions:
- Lambda: Full access to create/update/delete functions
- IAM: Manage roles and policies
- API Gateway: Full access to HTTP APIs
- CloudWatch Logs: Create log groups and streams

### 2. Quick Start

1. Clone the repository
```bash
git clone 
cd aws-api-gateway
```

2. Configure AWS credentials locally
```bash
aws configure
```

3. Customize project name (optional)
```bash
# Edit terraform/variables.tf and change the default project_name
# to avoid naming conflicts with existing resources
```

4. Deploy infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

5. Test the API
```bash
curl $(terraform output -raw api_url)
```

## Project Structure
```
aws-api-gateway/
├── .github/workflows/    # GitHub Actions CI/CD
├── terraform/            # Infrastructure as Code
│   ├── main.tf          # Main resources
│   ├── variables.tf     # Configurable variables
│   ├── outputs.tf       # Output values
│   └── backend.tf       # State backend config
├── src/lambda/          # Lambda function code
│   └── hello/           # Sample Lambda function
├── scripts/             # Deployment helper scripts
└── tests/               # Integration tests
```

## Deployment

### Manual Deployment
```bash
./scripts/deploy.sh
```

### CI/CD (GitHub Actions)
Push to `main` branch to trigger automatic deployment:
```bash
git add .
git commit -m "Deploy changes"
git push origin main
```

The workflow will:
1. Configure AWS credentials from secrets
2. Initialize Terraform
3. Plan infrastructure changes
4. Apply changes (on push to main)

## Testing

Run integration tests:
```bash
cd tests/integration
export API_URL=$(cd ../../terraform && terraform output -raw api_url)
python api_test.py
```

## Configuration

Edit `terraform/variables.tf` to customize:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `project_name` | Prefix for all resources | `my-api` |
| `environment` | Environment name | `dev` |

## Cleanup

**Warning:** This will destroy all resources!
```bash
./scripts/destroy.sh
```

Or manually:
```bash
cd terraform
terraform destroy
```

## Troubleshooting

### "Could not load credentials from any providers"

**Problem:** GitHub Actions workflow fails to authenticate with AWS.

**Solution:**
1. Verify GitHub Secrets are set correctly:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` exist and are not empty
2. Test credentials locally:
```bash
   aws sts get-caller-identity
```
3. Check IAM user has required permissions

### "EntityAlreadyExists: Role with name X already exists"

**Problem:** Resources from a previous deployment still exist.

**Solutions:**

**Option A - Change project name:**
```bash
# Edit terraform/variables.tf
variable "project_name" {
  default     = "my-api-v2"  # Use a unique name
}
```

**Option B - Delete existing resources:**
```bash
# Delete IAM role
aws iam detach-role-policy \
  --role-name my-api-lambda-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name my-api-lambda-role

# Delete Lambda function
aws lambda delete-function --function-name my-api-hello --region us-east-1

# Delete API Gateway (get ID from error message)
aws apigatewayv2 delete-api --api-id  --region us-east-1
```

**Option C - Import existing resources:**
```bash
cd terraform
terraform import aws_iam_role.lambda_role my-api-lambda-role
terraform import aws_lambda_function.hello my-api-hello
# Continue for other resources...
```

### Terraform State Lock

If deployment fails with a state lock error:
```bash
cd terraform
terraform force-unlock 
```

### API Returns 403/404

**Problem:** API endpoint returns errors.

**Solution:**
1. Verify Lambda has correct permissions:
```bash
   aws lambda get-policy --function-name my-api-hello
```
2. Check API Gateway stage is deployed:
```bash
   aws apigatewayv2 get-stages --api-id 
```
3. View Lambda logs:
```bash
   aws logs tail /aws/lambda/my-api-hello --follow
```

## Common Commands
```bash
# View outputs
terraform output

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# View state
terraform state list

# Get specific output
terraform output -raw api_url

# Refresh state
terraform refresh
```

## Security Best Practices

- **Never commit AWS credentials** to the repository
- Use least-privilege IAM policies
- Enable MFA for AWS accounts
- Rotate credentials regularly
- Use AWS Secrets Manager for sensitive data
- Enable API Gateway access logging
- Implement request throttling and API keys for production

## Next Steps

- Add authentication (Cognito, API Keys, Lambda authorizers)
- Implement request/response validation
- Set up custom domain with Route53
- Add more Lambda functions and routes
- Configure CORS for web applications
- Add monitoring and alerting with CloudWatch
- Set up multiple environments (dev, staging, prod)
- Enable AWS WAF for API protection

## Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## License

MIT
