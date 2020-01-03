#
# This outputs to the console asking for the SSH key for the EC2 instances
# You should have created a key pair in advance
#
variable "ec2_key_name" {
  description = "AWS EC2 Key name for SSH access"
  type        = string
}

variable "bigip_count" {
  description = "How many BIG-IPs should we deploy"
  type        = string
}

