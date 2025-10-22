# AWS API Gateway Project

A basic AWS API Gateway setup with Lambda integration using Terraform.

## Prerequisites

- AWS Account
- AWS CLI configured
- Terraform >= 1.0
- Node.js >= 18.x

## Quick Start

1. Clone the repository
```bash
git clone <your-repo-url>
cd aws-api-gateway
```

2. Configure AWS credentials
```bash
aws configure
```

3. Deploy infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

4. Test the API
```bash
curl $(terraform output -raw api_url)
```

## Project Structure

- `terraform/` - Infrastructure as Code
- `src/lambda/` - Lambda function code
- `scripts/` - Deployment scripts
- `tests/` - Integration tests
- `.github/workflows/` - CI/CD pipelines

## Deployment

### Manual Deployment
```bash
./scripts/deploy.sh
```

### CI/CD
Push to `main` branch to trigger automatic deployment via GitHub Actions.

## Testing

```bash
cd tests/integration
export API_URL=$(cd ../../terraform && terraform output -raw api_url)
python api_test.py
```

## Cleanup

```bash
./scripts/destroy.sh
```

## Configuration

Edit `terraform/variables.tf` to customize:
- AWS region
- Project name
- Environment

## License

MIT
