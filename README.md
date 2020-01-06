# terraform-aws-sslo-lab

Terraform Version supported = Terraform v0.12.9

AWS Provider version supported = v2.43.0

Terraform code to deploy a SSLO lab in AWS...aka Lab in a Box.

##Caution, this code deploys actual AWS infrastructure, therefore this will cost $, loot, ends, greenbacks...etc. Deploy at your own peril.##

This IaC supports a L3 Reverse Proxy Inbound SSLO topology.


You will need to provide your access key and secret in order to connect to AWS.
It is recommended to place your tokens in a separate file and call them in main.tf
See this file link for help.
https://www.terraform.io/docs/providers/aws/index.html

provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

This template uses AWS Gov region and custom AMI's for the Jumpbox and Firewall.
If you need to use a different region then replace the regions in the main.tf

There are variables in the variable.tf set for the availability zones.

The jumpbox is a Windows Server 2019 box with RDS and ADDS roles installed.  This allows for the creation of unlimited AD users and more importantly RDS users.  This allows for a single jump box.


