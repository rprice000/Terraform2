# Product Overview

This project provisions a complete AWS WordPress hosting infrastructure using Infrastructure as Code (IaC) principles. It creates a production-ready, secure, and scalable multi-tier architecture for hosting WordPress applications on AWS.

## Key Features

- **Multi-tier Architecture**: Separate public and private subnets with proper network segmentation
- **High Availability**: Multi-AZ deployment with Application Load Balancer
- **Security-First Design**: Defense in depth with Security Groups, NACLs, and private subnet isolation
- **Full Automation**: Complete WordPress deployment through AWS Systems Manager (SSM) scripts
- **Cost-Effective**: Uses t2.micro instances suitable for development and small production workloads

## Target Use Cases

- Development and testing WordPress environments
- Small to medium WordPress production deployments
- Learning AWS networking and security best practices
- Infrastructure as Code demonstrations
- Automated WordPress deployment scenarios

## Architecture Benefits

- WordPress instances isolated in private subnets for security
- Custom NAT instance for controlled internet access
- Load balancer ready for horizontal scaling
- No direct SSH access required (SSM-based management)
- Complete automation from infrastructure to application deployment