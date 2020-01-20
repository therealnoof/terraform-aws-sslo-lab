#
# This outputs to the console asking for the SSH key for the EC2 instances
# You should have created a key pair in advance
#
variable "ec2_key_name" {
  description = "AWS EC2 Key name for SSH access"
  type        = string
}

#
# Outputs to the console asking for the number of BIG-IPs/Students to deploy
#
variable "bigip_count" {
  description = "How many BIG-IPs should we deploy"
  type        = string
}

#
# Region - hard coded
#
variable "region" {
  description = "Set the Region"
  type        = string
  default     = "us-gov-west-1"
}

#
# Availability Zone - hard coded
#
variable "az" {
  description = "Set Availability Zone"
  type        = string
  default     = "us-gov-west-1a"
}

#
# Jump Box AMI - hard coded
#
variable "jumpbox_ami" {
  description = "Custom Public Windows Server AMI with ADDS and RDS roles installed"
  type        = string
  default     = "ami-f9456498"
}

#
# Palo Alto AMI - hard coded
#
variable "paloalto_ami" {
  description = "This AMI is a standard marketplace object. It is suggested to use a custom AMI here"
  type        = string
  default     = "ami-f38fab92"
}

