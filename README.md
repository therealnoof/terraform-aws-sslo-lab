![f5](https://user-images.githubusercontent.com/18743780/72476144-74b9cd80-37ba-11ea-82f3-81d37306b20e.png)![aws](https://user-images.githubusercontent.com/18743780/72476149-76839100-37ba-11ea-90ad-2da2bcfe2ecb.png)![terraform](https://user-images.githubusercontent.com/18743780/72476158-7a171800-37ba-11ea-95dc-1f58f7974150.png)

# Terraform AWS SSLO Lab

Terraform Version supported = Terraform v0.12.9

AWS Provider version supported = v2.43.0

Terraform code to deploy a SSLO lab in AWS...aka Lab in a Box.

##Caution, this code deploys actual AWS infrastructure, therefore this will cost $. Deploy at your own risk.##

##For Lab or demostration purposes only do not use this for a production environment.##

##Contact your F5 Sales team for architecture assistance##

This IaC supports a L3 Reverse Proxy Inbound SSLO topology.


You will need to provide your access key and secret in order to connect to AWS.
It is recommended to place your tokens in a separate file and call them in main.tf
See this file link for help.
https://www.terraform.io/docs/providers/aws/index.html

provider "aws" {
  region = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

This template uses AWS Gov region and a custom AMI for the Jumpbox.
If you need to use a different region then replace the regions in the main.tf

There are variables in the variable.tf set for the availability zones and AMI's.

The jumpbox is a Windows Server 2016 box with RDS and ADDS roles installed.  This allows for the creation of unlimited AD users and RDS users and allows for a single jump box.

The instructor will need to distribute the key used to intially access the instances.  You can place this key in the Public Documents folder on the desktop or use a s3 bucket.

The firewall used is a Palo Alto. The reason you ask? Palo Alto's are almost ubiquitous these days. My customers almost use them exclusively, so I thought let's use a real world security device.  Feel free to use whatever you want, just change the AMI. The version used is a Bundle 1 and costs around $1.15 per hour. The instructor will have to configure the Palo at first spin up. There is a file in the repo covering the configuration steps or follow the link below to the deployment guide. Its a fairly simple configuration.  I would recommend creating a custom image after configuration to save state.  In addition, I may consider implementing bootstrapping on the firewall in future versions of this lab to automagic this process.

# Lab or Deployment Pre-Reqs

1.	You should have some experience or familiarity with AWS, Terraform, Github, F5, and overall networking.

2.	You will need to copy or git clone this repo in order to launch this lab and it should go without saying that you have Terraform installed on your local machine.
    https://learn.hashicorp.com/terraform/getting-started/install.html

3.	You should have basic Linux command line skills.

4.	You will need to have an AWS Secret Key and Access Key in order to access the AWS environment.  You will need to create this before you deploy.  The Terraform template references the keys in an external file.
    https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/

5.	You will need to have a key pair created before you launch the EC2 instances.  These are used to initially access the instances in order to configure the admin passwords. 
    https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

6.	You will need to configure static routes on the Palo Alto firewall for each student/BIG-IP.  This lab uses a single firewall for the sake of cost savings.  Therefore, static routes are used to direct destination traffic from the VIP to the correct ingress interface IP on the BIG-IP.
Example: Virtual Routers > Static Routes > Add 
Destination: <VIP>10.0.4.237/32 , Interface 1/2, Next Hop Address 10.0.6.100 < BIG-IP Self
                                                                                     
This will ensure traffic is directed to the correct students BIGIP.  If you are unfamiliar with Palo Alto heres a guide to configure static routes. In addition, the guide in this repo covers the steps to configure.
    https://docs.paloaltonetworks.com/pan-os/9-0/pan-os-admin/networking/static-routes/configure-a-static-route  
                                                                                     
   Here is a link to download the Palo configuration steps.  Or you can follow via the file "paloalto-configuration" in this repo.
    https://sslo-lab.s3-us-gov-west-1.amazonaws.com/sslo-lab-docs/Configuring+the+Palo+Alto+Firewall+for+SSLO.docx                                                                              
                                                                                     
                                                                                     
7.	This lab uses a custom AMI for the jump box.  The custom AMI’s are referenced in the variable.tf file in Terraform.

8.  This lab uses a free NGINX web server from the marketplace, a PAYGO Palo Alto, BYOL BIG-IP or BIG-IP's and a Windows Server 2016 instance.  SSLO is not part of BEST licensing therefore you cannot use PAYGO.  Reach out to your F5 sales team for trial licenses.

9.  Jumpbox credentials = f5admin | F5twister!

# Terraform Commands

terraform init

terraform plan

terraform apply

terrafrom destroy

# Lab Guide

The lab guide is for the student and does not provide any pre-reqs like BYOL licensing or IP Addressing.

Therefore it is the lab instructors job to procure BYOL trial licenses and to provide the IP addressing after the       Terraform template has deployed.

Lab guide Link: https://sslo-lab.s3-us-gov-west-1.amazonaws.com/sslo-lab-docs/SSL+Orchestrator+6.0+Lab+Guide+(AWS+Reverse+Proxy+version)+v1.pdf

# Topology
![Screen Shot 2020-01-15 at 4 33 22 PM](https://user-images.githubusercontent.com/18743780/72473482-c4959600-37b4-11ea-8c88-c0fb85eceb9e.png)
