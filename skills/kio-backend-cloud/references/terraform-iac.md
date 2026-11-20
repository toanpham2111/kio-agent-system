# Terraform Modules & Cloud Architecture

## 1. Remote State Locking (AWS S3 + DynamoDB)
```hcl
terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }

  backend "s3" {
    bucket         = "kio-terraform-state-prod"
    key            = "core/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "kio-terraform-locks"
    encrypt        = true
  }
}
```

## 2. Secure VPC & Bastion Pattern
- Keep all databases (RDS, Aurora) and worker nodes strictly inside **private subnets** with NO public IP.
- Egress outbound traffic through NAT Gateways.
- Enforce encrypted EBS storage and transit encryption (TLS 1.3).
