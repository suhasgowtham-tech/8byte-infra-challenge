![CI/CD Pipeline](https://github.com/suhasgowtham-tech/8byte-infra-challenge/actions/workflows/deploy.yml/badge.svg)

# Multi-Tier AWS Production Infrastructure & Managed CI/CD Engine

This repository contains the production-grade, multi-tier infrastructure blueprints and automated continuous deployment engine designed for the Octa Byte AI DevOps Engineer Assessment. The architecture focuses on high security perimeter isolation, complete state telemetry tracking, and automated zero-downtime rolling execution matrices.

---

## 1. Architectural Strategy & Design Choices

The entire layout is engineered modularly to decouple discrete business tiers, minimizing attack surfaces while maximizing system availability.

### Network Isolation Grid (VPC Layout)
- **Public DMZ Layer:** Hosts internet-facing Application Load Balancers (ALBs) to gracefully intercept incoming user actions. No direct backend compute nodes reside here.
- **Private Application Tier:** Hosts isolated ECS Container Tasks running within a dynamic auto-scaling perimeter. These tasks accept incoming traffic exclusively forwarded via target tracking routes from the ALB.
- **Isolated Database Tier:** Completely sealed RDS PostgreSQL layer with zero public routes or internet egress capability.

### Compute & Database State Selection
- **AWS ECS (Fargate):** Selected for application hosting to leverage serverless runtime environments. This eliminates the operational overhead of manually patching underlying EC2 hypervisors while enforcing strict container-level resource boundaries.
- **Amazon RDS (PostgreSQL 15.4):** Configured with variable max-allocated auto-scaling up to 100GB to accommodate dynamic data growth without risk of storage-exhaustion crashes.

---

## 2. Infrastructure Deployment Guide

### Prerequisites
- HashiCorp Terraform CLI (v1.5.0+)
- AWS CLI configured with administrative execution rights

### Bootstrap State Backend (Run Once)
```bash
aws s3 mb s3://8byte-infra-terraform-state --region us-east-1

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Execution Sequence
```bash
# Initialize backend providers and pull down core module logic
terraform init

# Run syntax verification checks to validate structural code integrity
terraform validate

# Generate an execution plan to audit pending cloud modifications
terraform plan

# Apply the structural additions directly to your target cloud environment
terraform apply -auto-approve
```

---

## 3. Project Structure

```
8byte-infra-challenge/
├── .github/
│   └── workflows/
│       └── deploy.yml           # 4-stage CI/CD pipeline
├── app/
│   ├── server.js                # Node.js application
│   ├── Dockerfile               # Container definition
│   └── package.json
└── terraform/
    ├── backend.tf               # S3 remote state + DynamoDB lock
    ├── state-bootstrap.tf       # State infrastructure resources
    ├── main.tf                  # Root module orchestration
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── networking/          # VPC, subnets, NAT, IGW
        ├── compute/             # ECS, ALB, ECR, security groups
        ├── database/            # RDS PostgreSQL
        └── monitoring/          # CloudWatch dashboards, alarms, logs
```

---

## 4. CI/CD Pipeline

4-stage GitHub Actions pipeline:

| Stage | Trigger | What It Does |
|---|---|---|
| CI Test & Security | PR + Push | npm install, tests, npm audit |
| Build & Push | Merge to main | Docker build, Trivy scan, push to ECR |
| Deploy Staging | Auto after build | ECS rolling update on staging |
| Deploy Production | Manual approval | Production ECS deploy after gate |

### Pipeline Features
- Vulnerability scanning via **Trivy** (container) and **npm audit** (dependencies)
- **Manual approval gate** on production environment
- Failure notifications on every stage
- Branch protection via GitHub Environments

---

## 5. Monitoring & Logging

### CloudWatch Dashboards
- **SRE Platform Dashboard** — ECS CPU/Memory, ALB request rate, error count, p99 latency, healthy host count
- **Database Analytics Dashboard** — RDS CPU, connections, free storage, read/write latency, IOPS

### Alarms Configured

| Alarm | Threshold |
|---|---|
| ECS CPU High | ≥ 70% for 2 periods |
| ECS Memory High | ≥ 70% for 2 periods |
| RDS CPU High | > 75% for 2 periods |
| RDS Storage Low | < 5GB free |
| ALB 5XX Errors | > 10 in 60s |
| ALB Latency High | p99 > 2s |

### Log Groups

| Group | Purpose | Retention |
|---|---|---|
| /ecs/{env}-core-api | Application logs | 30 days |
| /8byte/{env}/system | System logs | 30 days |
| /8byte/{env}/access | Access logs | 30 days |

---

## 6. Security Considerations

- **RDS in private subnet** — no public accessibility
- **S3 state bucket** — AES256 encryption, public access fully blocked, versioning enabled
- **DynamoDB state lock** — prevents concurrent terraform runs
- **Security groups** — least privilege, ECS only accepts traffic from ALB
- **ECR image scanning** — Trivy scans every container build for CRITICAL/HIGH CVEs
- **GitHub Secrets** — AWS credentials stored as encrypted repository secrets, never in code
- **ECS task IAM roles** — principle of least privilege per service

### Secret Management
AWS credentials are stored in GitHub repository secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). In production, this would be replaced with **OIDC-based IAM role federation** to eliminate long-lived credentials entirely.

### Backup Strategy
- **RDS automated backups** — 7-day retention window configured
- **S3 state versioning** — every terraform state version retained and recoverable
- **ECR image tags** — images tagged with git SHA, every deployment version retained

---

## 7. Cost Optimization

- **ECS Fargate** — pay only for actual task runtime, no idle EC2 cost
- **RDS gp3 storage** — 20% cheaper than gp2 at same performance
- **CloudWatch 30-day retention** — balances observability with storage cost
- **NAT Gateway single AZ** — for non-production (multi-AZ for production)
- **DynamoDB PAY_PER_REQUEST** — no provisioned capacity waste

---

## 8. Outputs

After `terraform apply`:

| Output | Description |
|---|---|
| `application_load_balancer_url` | Public endpoint to reach the application |