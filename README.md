![CI/CD Pipeline](https://github.com/suhasgowtham-tech/8byte-infra-challenge/actions/workflows/deploy.yml/badge.svg)

\# Multi-Tier AWS Production Infrastructure \& Managed CI/CD Engine



This repository contains the production-grade, multi-tier infrastructure blueprints and automated continuous deployment engine designed for the Octa Byte AI DevOps Engineer Assessment. The architecture focuses on high security perimeter isolation, complete state telemetry tracking, and automated zero-downtime rolling execution matrices.



\---



\## 1. Architectural Strategy \& Design Choices



The entire layout is engineered modularly to decouple discrete business tiers, minimizing attack surfaces while maximizing system availability.



\### Network Isolation Grid (VPC Layout)

\* \*\*Public DMZ Layer:\*\* Hosts internet-facing Application Load Balancers (ALBs) to gracefully intercept incoming user actions. No direct backend compute nodes reside here.

\* \*\*Private Application Tier:\*\* Hosts isolated ECS Container Tasks running within a dynamic auto-scaling perimeter. These tasks accept incoming traffic exclusively forwarded via target tracking routes from the ALB.

\* \*\*Isolated Database Tier:\*\* Completely sealed RDS PostgreSQL layer with zero public routes or internet egress capability. 



\### Compute \& Database State Selection

\* \*\*AWS ECS (Fargate):\*\* Selected for application hosting to leverage serverless runtime environments. This eliminates the operational overhead of manually patching underlying EC2 hypervisors while enforcing strict container-level resource boundaries.

\* \*\*Amazon RDS (PostgreSQL 15.4):\*\* Configured with variable max-allocated auto-scaling up to 100GB to accommodate dynamic data growth without risk of storage-exhaustion crashes.



\---



\## 2. Infrastructure Deployment Guide



\### Prerequisites

\* HashiCorp Terraform CLI (v1.5.0+)

\* AWS CLI configured with administrative execution rights



\### Execution Sequence

To initialize, validate, and execute the multi-module infrastructure layout, run the following commands inside the `terraform/` directory:



```bash

\# Initialize backend providers and pull down core module logic

terraform init



\# Run syntax verification checks to validate structural code integrity

terraform validate



\# Generate an execution plan to audit pending cloud modifications

terraform plan



\# Apply the structural additions directly to your target cloud environment

terraform apply -auto-approve




