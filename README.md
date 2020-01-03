# terraform-aws-sslo-lab
Terraform code to deploy a SSLO lab in AWS...aka Lab in a Box.

This IaC supports a L3 Reverse Proxy Inbound SSLO topology.

Terraform Version supported = Terraform v0.12.9

AWS Provider version supported = v2.43.0

You will need to provide your access key and secret in order to connect to AWS.
These values are located at the top of the main.tf file.
This template uses AWS Gov and custom AMI's for the Jumpbox and Firewall.

The jumpbox is a Windows Server 2019 box with RDS and ADDS roles installed.  This allows for the creation of unlimited AD users and more importantly RDS users.  This allows for a single jump box.


