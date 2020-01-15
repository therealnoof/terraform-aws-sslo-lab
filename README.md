![f5](https://user-images.githubusercontent.com/18743780/72476144-74b9cd80-37ba-11ea-82f3-81d37306b20e.png)

# Terraform AWS SSLO Lab

Terraform Version supported = Terraform v0.12.9

AWS Provider version supported = v2.43.0

Terraform code to deploy a SSLO lab in AWS...aka Lab in a Box.

##Caution, this code deploys actual AWS infrastructure, therefore this will cost $. Deploy at your own peril.##

##For Lab or demostration purposes only do not use this for a productionn environment. Contact F5 Sales team for help##

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

There are variables in the variable.tf set for the availability zones and custom AMI's.

The jumpbox is a Windows Server 2019 box with RDS and ADDS roles installed.  This allows for the creation of unlimited AD users and RDS users.  This allows for a single jump box.

The firewall used is a Palo Alto.  The AMI image has some pre-configurations and static IP addresses for the interfaces as noted in the main.tf. The administrator will have to configure the static routes to support the number of students/bigip's.

# Lab or Deployment Pre-Reqs

1.	You should have some experience or familiarity with AWS, Terraform and Github

2.	You will need to download the Terraform code from Github in order to launch this lab and it should go without saying that     you have Terraform installed on your local machine.

3.	You should have basic skills to access Linux CLI

4.	You will need to have an AWS Secret Key and Access Key in order to access the AWS environment.  You will need to create this before you deploy.  The Terraform template references the keys in an external file.

5.	You will need to have a key pair created before you launch the EC2 instances.  These are used to initially access the instances in order to configure the admin passwords. 

6.	You will need to configure static routes on the Palo Alto firewall for each student/BIG-IP.  This lab uses a single firewall for the sake of cost savings.  Therefore, static routes are used to direct destination traffic from the VIP to the correct ingress interface IP on the BIG-IP.
Example: Virtual Routers > Static Routes > Add 
Destination: <VIP>10.0.4.237/32 , Interface 1/2, Next Hop Address 10.0.6.100 < BIG-IP Self
This will ensure traffic is directed to the correct students BIGIP.
                                                                                     
7.	This lab uses custom AMI’s for the jumpbox and Palo Alto.  These have pre-configurations applied.  Feel free to use whatever images you want.  The custom AMI’s are referenced in the variable.tf file in Terraform.

# Terraform Commands

terraform plan

terraform apply

terrafrom destroy

# Topology
![Screen Shot 2020-01-15 at 4 33 22 PM](https://user-images.githubusercontent.com/18743780/72473482-c4959600-37b4-11ea-8c88-c0fb85eceb9e.png)
