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
  description = "Identify the custom AMI"
  type        = string
  default     = "ami-cc8aacad"
}

#
# Palo Alto AMI - hard coded
#
variable "paloalto_ami" {
  description = "Identify the custom AMI"
  type        = string
  default     = "ami-31ac8a50"
}

