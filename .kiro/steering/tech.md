# Technology Stack

## Infrastructure as Code
- **Terraform**: Primary IaC tool for AWS resource provisioning
- **AWS Provider**: Version 5.82.2 (locked in .terraform.lock.hcl)
- **Target Region**: us-east-2 (Ohio)

## AWS Services Used
- **Compute**: EC2 instances (Amazon Linux 2023 for NAT, Ubuntu 24.04 for WordPress)
- **Networking**: VPC, Subnets, Internet Gateway, Route Tables, Elastic IP
- **Load Balancing**: Application Load Balancer with Target Groups
- **Security**: Security Groups, Network ACLs, IAM Roles and Policies
- **Automation**: AWS Systems Manager (SSM) for configuration management

## Application Stack (LEMP)
- **Linux**: Ubuntu Server 24.04 LTS
- **Nginx**: Web server and reverse proxy
- **MySQL**: Database server
- **PHP**: Server-side scripting language
- **WordPress**: Content Management System

## Common Commands

### Terraform Operations
```bash
# Initialize Terraform (first time setup)
terraform init

# Plan infrastructure changes
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy infrastructure
terraform destroy

# Format Terraform files
terraform fmt

# Validate Terraform configuration
terraform validate
```

### SSM Script Execution
SSM scripts must be executed in the specific order defined in `SSM_Script_Order.md`. Scripts are executed through AWS Systems Manager console or CLI.

### Key Pair Requirement
- A key pair named "test_key" must exist in the target AWS region before deployment
- This key pair is referenced by both NAT and WordPress instances

## Configuration Management
- **SSM Documents**: 18 YAML-based automation scripts for complete WordPress setup
- **IAM Integration**: Instances configured with SSM permissions for remote management
- **Logging**: Each SSM script logs execution status to `/var/log/` directory