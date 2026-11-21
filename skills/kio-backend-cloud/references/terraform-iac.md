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
    use_lockfile   = true   # Terraform >= 1.10: native S3 locking; dynamodb_table is deprecated
    encrypt        = true
  }
}
```

## 2. Secure VPC & Bastion Pattern
- Keep all databases (RDS, Aurora) and worker nodes strictly inside **private subnets** with NO public IP.
- Egress outbound traffic through NAT Gateways.
- Enforce encrypted EBS storage and transit encryption (TLS 1.3).

> On Terraform < 1.10 keep `dynamodb_table = "kio-terraform-locks"` instead of `use_lockfile`. Enable **versioning** on the state bucket and block public access; state files contain secrets.

## 3. Layout
```
infra/
├── modules/            # reusable, no provider/backend blocks, versioned
│   ├── network/        # variables.tf, main.tf, outputs.tf, versions.tf
│   └── postgres/
└── envs/
    ├── staging/        # backend + provider + module calls, one state per env
    └── prod/
```
- One state per environment (and per blast radius: network, data, apps). Never share state between prod and staging.
- Prefer separate directories over `terraform workspace` for environments with different access rules.

## 4. Module conventions
```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "environment must be staging or prod."
  }
}

resource "aws_db_instance" "main" {
  identifier                  = "app-${var.environment}"
  engine                      = "postgres"
  engine_version              = "16"
  instance_class              = var.instance_class
  allocated_storage           = 50
  storage_encrypted           = true
  publicly_accessible         = false
  multi_az                    = var.environment == "prod"
  deletion_protection         = var.environment == "prod"
  backup_retention_period     = 7
  manage_master_user_password = true          # password lives in Secrets Manager, not in state
  db_subnet_group_name        = var.db_subnet_group
  vpc_security_group_ids      = [var.db_sg_id]

  lifecycle { prevent_destroy = true }
}

output "db_endpoint" { value = aws_db_instance.main.endpoint }
```
- Tag everything via provider `default_tags` (`environment`, `owner`, `cost_center`).
- Mark sensitive outputs `sensitive = true`; never put secrets in `.tfvars` that are committed.
- Pin provider versions (`~> 5.40`) and commit `.terraform.lock.hcl`.

## 5. Workflow
1. `terraform fmt -check && terraform validate && tflint` on every PR.
2. Security scan: `checkov -d .` or `trivy config .`.
3. `terraform plan -out=tfplan` in CI, post the plan to the PR, require review.
4. `terraform apply tfplan` only from CI with OIDC credentials, only the reviewed plan.
5. Detect drift on a schedule (`terraform plan -detailed-exitcode`, exit code 2 = drift).

## 6. Never
- Never `terraform apply` prod from a laptop, or `-auto-approve` without a reviewed plan.
- Never edit state by hand; use `terraform state mv` / `import` blocks / `moved` blocks.
- Never open `0.0.0.0/0` on database or SSH ports; use SSM Session Manager instead of bastions where possible.
