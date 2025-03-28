

NAT EC2 Instance Security Group Inbound Rules
SSH             22                  0.0.0.0/0
All Traffic     All                 10.0.3.0/24
All ICMP-IPv4                       10.0.3.0/24

NAT EC2 Instance Security Group Outbound Rules
All Traffic     All                 0.0.0.0./0
SSH             22                  Wordpress Security Group
HTTP            80                  0.0.0.0/0                 
HTTPS           443                 0.0.0.0/0
CUSTOM TCP      1024-65535          Wordpress Security Group
==========================================================================

Wordpress Instance Security Group Inbound Rules
HTTP            80                  Application Load Balancer Security Group                  
HTTPS           443                 Application Load Balancer Security Group 
SSH             22                  NAT EC2 Instance Security Group
CUSTOM TCP      1024-65535          NAT EC2 Instance Security Group
MYSQL/Aurora    3306                Wordpress Security Group


Wordpress Instance Secruity Group Outbound Rules
All Traffic     All                 NAT EC2 Instance Security Group
MYSQL/Aurora    3306                Wordpress Security Group
==========================================================================



Application Load Balancer Security Group Inbound Rules
HTTP            80                  0.0.0.0/0                 
HTTPS           443                 0.0.0.0/0

Application Load Balancer Security Group Outbound Rueles
All Traffic     All                 Wordpress Security Group


==========================================================================





Public Subnet NACL Inbound Rules
100     SSH             22              0.0.0.0/0       Allow
110     HTTP            80              10.0.3.0/24     Allow
120     HTTPS           443             10.0.3.0/24     Allow
140     Custom TCP      1024-65535      10.0.3.0/24     Allow
130     Custom TCP      1024-65535      0.0.0.0/0       Allow
*       All Traffic     All             0.0.0.0/0       Deny

Public Subnet NACL Outbound Rules
100     All traffic                     0.0.0.0/0       Allow
110     Custom TCP      1024-65535      10.0.3.0/24     Allow
120     HTTP            80              0.0.0.0/0       Allow
130     HTTPs           443             0.0.0.0/0       Allow    
140     Custom TCP      1024-65535      0.0.0.0/0       Allow 
*       All Traffic     All             0.0.0.0/0       Deny
==========================================================================


Private Subnet NACL Inbound Rules
100     SSH             22              10.0.1.0/24     Allow
120     Custom TCP      1024-65535      10.0.1.0/24     Allow
130     Custom TCP      1024-65535      0.0.0.0/0       Allow
140     MYSQL/Aurora    3306            10.0.3.0/24     Allow
*       All Traffic     All             0.0.0.0/0       Deny

Private Subnet NACL Outbound Rules
100     All traffic                     10.0.1.0/0      Allow
110     HTTP            80              0.0.0.0/0       Allow  
120     HTTPS           443             0.0.0.0/0       Allow
130     Custom TCP      1024-65535      10.0.1.0/24     Allow
140     MYSQL/Aurora    3306            10.0.3.0/24     Allow
*       All Traffic     All             0.0.0.0/0       Deny

==========================================================================



