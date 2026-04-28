# AWS WordPress Infrastructure with Terraform

## Overview

This project provisions a complete AWS infrastructure for hosting a WordPress application using Terraform. It creates a secure, scalable architecture with proper network segmentation, load balancing, and automated configuration management through AWS Systems Manager (SSM).

## Architecture

The infrastructure implements a multi-tier architecture with the following components:

### Network Infrastructure
- **VPC**: Custom VPC (10.0.0.0/16) with DHCP options
- **Subnets**: 
  - 2 Public subnets (10.0.1.0/24, 10.0.2.0/24) across different AZs
  - 1 Private subnet (10.0.3.0/24) for WordPress instances
- **Internet Gateway**: Provides internet access to public subnets
- **NAT Instance**: Custom NAT instance in public subnet for private subnet internet access
- **Elastic IP**: Static IP for the NAT instance

### Security
- **Security Groups**: Granular security rules for NAT, ALB, and WordPress instances
- **Network ACLs**: Additional network-level security for public and private subnets
- **IAM Roles**: Dedicated roles for NAT and WordPress instances with SSM permissions

### Compute & Load Balancing
- **NAT Instance**: Amazon Linux 2023 t2.micro instance for network address translation
- **WordPress Instance**: Ubuntu Server 24.04 t2.micro instance in private subnet
- **Application Load Balancer**: Internet-facing ALB distributing traffic to WordPress instances
- **Target Group**: Health-checked target group for WordPress instances

### Automation
- **SSM Scripts**: 18 automated configuration scripts for complete WordPress setup
- **IAM Integration**: Instances configured with SSM permissions for remote management

## SSM Configuration Scripts

The project includes a comprehensive set of SSM documents that automate the entire WordPress installation and configuration process:

1. **Infrastructure Setup**
   - NAT instance configuration with IP forwarding and iptables
   - Ubuntu system updates and upgrades

2. **LEMP Stack Installation**
   - Nginx web server installation and configuration
   - MySQL database server setup
   - PHP installation and configuration

3. **WordPress Deployment**
   - WordPress download and installation
   - Database and user creation
   - WordPress configuration file setup
   - Security key generation and replacement

4. **Integration & Finalization**
   - AWS CLI installation
   - ALB DNS name integration with WordPress
   - Service restarts and final configuration

## Security Features

- **Network Segmentation**: WordPress instances isolated in private subnets
- **Least Privilege Access**: Security groups allow only necessary traffic
- **Defense in Depth**: Both security groups and NACLs provide layered security
- **Secure Database Access**: MySQL only accessible within the VPC
- **SSM-based Management**: No direct SSH access required for instance management

## Key Files

- `main.tf`: Complete Terraform configuration for all AWS resources
- `SSM Scripts/`: Directory containing all automated configuration scripts
- `SSM_Script_Order.md`: Execution order for SSM scripts
- `Security_Group_NACL_Rules.md`: Detailed security rules documentation

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Key pair named "test_key" created in AWS (referenced in instances)
- Appropriate AWS permissions for VPC, EC2, IAM, and ALB resources

## Deployment

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Execute SSM scripts in order (see `SSM_Script_Order.md`)

## Architecture Benefits

- **High Availability**: Multi-AZ deployment with load balancing
- **Security**: Private subnet isolation with controlled access
- **Scalability**: Load balancer ready for additional instances
- **Automation**: Complete hands-off WordPress deployment
- **Cost Effective**: Uses t2.micro instances suitable for development/testing
- **Maintainability**: Infrastructure as Code with Terraform

## Network Flow

1. Internet traffic → ALB (public subnets)
2. ALB → WordPress instances (private subnet)
3. WordPress instances → NAT instance → Internet (for updates/downloads)
4. Database traffic stays within private subnet

This architecture provides a production-ready foundation for WordPress hosting on AWS with proper security, scalability, and automation practices.