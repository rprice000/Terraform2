# Project Structure

## Root Directory
- `main.tf` - Complete Terraform configuration containing all AWS resources
- `README.md` - Comprehensive project documentation and deployment guide
- `terraform.tfstate` - Terraform state file (managed automatically)
- `terraform.tfstate.backup` - Backup of previous Terraform state
- `.terraform.lock.hcl` - Terraform provider version lock file

## Configuration Files
- `SSM_Script_Order.md` - Execution sequence for SSM automation scripts
- `Security_Group_NACL_Rules.md` - Detailed security rules documentation
- `.gitignore` - Git ignore patterns for Terraform and sensitive files

## SSM Scripts Directory
Located in `SSM Scripts/` with numbered naming convention:
- `01_Configure_NAT_Instance.yaml` - NAT instance setup
- `02_Part_1_Update_and_Upgrade_Ubuntu.yaml` - System updates
- `03_Part_2_Install_Nginx.yaml` - Web server installation
- `04_Part_3_Install_MySQL.yaml` - Database installation
- `05_Part_4_Install_PHP.yaml` - PHP runtime installation
- `06-09_Part_5-8_*` - Nginx configuration and site setup
- `10-14_Part_9-13_*` - WordPress installation and configuration
- `15-18_Part_14-17_*` - Final configuration and integration

## Infrastructure Organization (main.tf)
Resources are organized in logical sections with comments:
1. **Provider Configuration** - AWS provider and region
2. **VPC and Networking** - VPC, subnets, gateways, route tables
3. **Security** - Security groups, NACLs, IAM roles and policies
4. **Compute** - EC2 instances (NAT and WordPress)
5. **Load Balancing** - ALB, target groups, listeners

## Naming Conventions
- **Resources**: Descriptive names with hyphens (e.g., `wordpress-alb`)
- **Tags**: PascalCase for Name tags (e.g., `MainVPC`, `WordPress-Instance`)
- **Files**: Snake_case for SSM scripts, kebab-case for documentation
- **Security Groups**: Suffix with `-sg` (e.g., `nat_sg`, `alb_sg`)

## Network Architecture
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-b)
- **Private Subnet**: 10.0.3.0/24 (AZ-a)
- **Availability Zones**: us-east-2a, us-east-2b

## Key Dependencies
- SSM scripts must be executed in numerical order
- NAT instance must be configured before WordPress instance internet access
- Key pair "test_key" must exist before Terraform deployment
- WordPress instance depends on ALB for health checks