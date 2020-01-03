#
# Provider Declared
#
provider "aws" {
  region = local.region
  access_key = "AKIAWX4W2N4FLS5BPFUS"
  secret_key = "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"
}

#
# Create a random id
#
resource "random_id" "id" {
  byte_length = 2
}

###########################
# Core Networking Created #
###########################

#
# Create the VPC 
#
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = format("%s-vpc-%s", local.prefix, random_id.id.hex)
  cidr                 = local.cidr
  azs                  = ["us-gov-west-1a"]
  enable_nat_gateway   = true
}

#
# Create the Route Table
#
resource "aws_route_table" "sslo-lab-route-table" {
  vpc_id                = module.vpc.vpc_id
  
    route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = "${aws_internet_gateway.sslo-lab-igw.id}"  
  }
  tags = {
    Name = "sslo-lab-route-table"
  }
} 

#
# Create the Route Table associations
#
resource "aws_route_table_association" "sslo-lab-route-table-association" {
  subnet_id             = "${aws_subnet.jumpbox.id}" 
  route_table_id        = "${aws_route_table.sslo-lab-route-table.id}"
}

resource "aws_route_table_association" "sslo-lab-route-table-association-1" {
  subnet_id             = "${aws_subnet.jumpbox-to-mgmt.id}"
  route_table_id        = "${aws_route_table.sslo-lab-route-table.id}"
}

resource "aws_route_table_association" "sslo-lab-route-table-association-2" {
  subnet_id             = "${aws_subnet.bigip-internal-to-webserver.id}"
  route_table_id        = "${aws_route_table.sslo-lab-route-table.id}"
}

#
# Create the Main Route Table asscociation
#
resource "aws_main_route_table_association" "sslo-lab-main-route-table-association" {
  vpc_id                = module.vpc.vpc_id
  route_table_id        = "${aws_route_table.sslo-lab-route-table.id}"
}


#
# Create the IGW
#
resource "aws_internet_gateway" "sslo-lab-igw" {
  vpc_id                = module.vpc.vpc_id
  tags = {
    Name = "sslo-lab-igw"
  }
}

##########################
# Jump Box Configs Begin #
##########################

#
# Create External Subnet for Jumpbox
#
resource "aws_subnet" "jumpbox" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "us-gov-west-1a"
  tags = {
    Name = "sslo-lab-jumpbox"
    Group_Name = "sslo-lab-jumpbox"
  }
}

#
# Create External(MGMT) Network Interface for Jumpbox
#
resource "aws_network_interface" "sslo-lab-jumpbox-external" {
  subnet_id             = "${aws_subnet.jumpbox.id}"
  security_groups       = ["${aws_security_group.jumpbox_external.id}", "${aws_security_group.jumpbox_to_mgmt.id}"]
  tags = {
    Name = "sslo-lab-external-interface-jumpbox"
  }
}

#
# Create Internal Network (2nd)Interface to access BIGIP MGMT for Jumbbox
#
resource "aws_network_interface" "sslo-lab-jumpbox-to-BIGIP-mgmt" {
  subnet_id             = "${aws_subnet.jumpbox-to-mgmt.id}"
  security_groups       = ["${aws_security_group.jumpbox_to_mgmt.id}"] 
  tags = {
    Name = "sslo-lab-jumpbox-to-mgmt"
  }
}

#
# Create Security Group for Jumpbox Public
#
resource "aws_security_group" "jumpbox_external" {
  vpc_id                = module.vpc.vpc_id
  description           = "sslo-lab-sg-jumpbox-external"
  name                  = "sslo-lab-sg-jumpbox-external"
  tags = {
    Name = "sslo-lab-sg-jumpbox-external"
  }
  ingress {
    # RDP (change to whatever ports you need)
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#
# Create EIP Association
#
resource "aws_eip_association" "eip" {
  network_interface_id        = "${aws_network_interface.sslo-lab-jumpbox-external.id}"
  allocation_id               = "eipalloc-723ff64f"
}

#
# Create Jump Box
#
resource "aws_instance" "jumpbox" {

  ami                         = "ami-bc89acdd"  
  instance_type               = "m4.xlarge"
  key_name                    = var.ec2_key_name  
  availability_zone           = "us-gov-west-1a"
  depends_on                  = ["aws_internet_gateway.sslo-lab-igw"]
  tags = {
    Name = "sslo-lab-jumpbox"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-jumpbox-to-BIGIP-mgmt.id}"
    device_index              = 1
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-jumpbox-external.id}"
    device_index              = 0
  }
}

#######################
# BIGIP Configs Begin #
#######################

#
# Create Management Subnet for Jumpbox to BIG-IP
#
resource "aws_subnet" "jumpbox-to-mgmt" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "us-gov-west-1a"
  tags = {
    Name = "sslo-lab-jumpbox-to-mgmt"
    Group_Name = "sslo-lab-jumpbox-to-mgmt"
  }
}

#
# Create Internal Subnet for the BIG-IP
#
resource "aws_subnet" "bigip-internal-to-webserver" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.3.0/24"
  availability_zone     = "us-gov-west-1a"
  tags = {
    Name = "sslo-lab-bigip-internal-to-webserver"
    Group_Name = "sslo-lab-bigip-internal-to-webserver"
  }
}

#
# Create Managment Network Interface for BIG-IP
#
resource "aws_network_interface" "sslo-lab-jumpbox-to-mgmt" {
  count                 = var.bigip_count
  subnet_id             = "${aws_subnet.jumpbox-to-mgmt.id}"
  security_groups       = ["${aws_security_group.jumpbox_to_mgmt.id}","${aws_security_group.bigip_to_internal_webserver.id}" ]
  tags = {
    Name = "sslo-lab-jumpbox-to-mgmt-interface"
  }
}

#
# Create Internal Network Interface for BIG-IP
#
resource "aws_network_interface" "sslo-lab-bigip-interal-to-webserver" {
  subnet_id             = "${aws_subnet.bigip-internal-to-webserver.id}"
  security_groups       = ["${aws_security_group.bigip_to_internal_webserver.id}"]
  tags = {
    Name = "sslo-lab-bigip-to-internal-webserver"
  }
}

#
# Create Security Group for BIGIP to Internal Web Server
#
resource "aws_security_group" "bigip_to_internal_webserver" {
  vpc_id                = module.vpc.vpc_id
  description           = "sslo-lab-sg-bigip_to_internal_webserver"
  name                  = "sslo-lab-sg-bigip_to_internal_webserver"
  tags = {
    Name = "sslo-lab-sg-bigip_to_internal_webserver"
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#
# Create Security Group for Jumpbox to BIGIP Mananement
#
resource "aws_security_group" "jumpbox_to_mgmt" {
  vpc_id                = module.vpc.vpc_id
  description           = "sslo-lab-sg-jumpbox-to-mgmt"
  name                  = "sslo-lab-sg-jumpbox-to-mgmt"
  tags = {
    Name = "sslo-lab-sg-jumpbox-to-mgmt"
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#
# Create Random Student ID up to 20
#
resource "random_integer" "student_number" {
  min                         = 1
  max                         = 20
}

#
# Create BIG-IP
#
resource "aws_instance" "bigip" {

  count                       = var.bigip_count
  ami                         = "ami-14520975"  
  instance_type               = "m4.4xlarge"
  key_name                    = var.ec2_key_name  
  availability_zone           = "us-gov-west-1a"
  depends_on                  = ["aws_internet_gateway.sslo-lab-igw"]
  tags = {
    Name = "sslo-lab-bigip,${random_integer.student_number.result}"
  }
  # set the mgmt interface 
  dynamic "network_interface" {
    for_each = toset([aws_network_interface.sslo-lab-jumpbox-to-mgmt[count.index].id])

    content {
      network_interface_id = network_interface.value
      device_index         = 0
    }
  }
}

############################
# Web Server Configs Begin #
############################

#
#
#
resource "aws_network_interface" "sslo-lab-webserver" {
  subnet_id             = "${aws_subnet.bigip-internal-to-webserver.id}"
  security_groups       = ["${aws_security_group.bigip_to_internal_webserver.id}"]
  tags = {
    Name = "sslo-lab-webserver"
  }
}

#
# Create Web Server
#
resource "aws_instance" "web-server" {

  count                       = 1
  ami                         = "ami-443f6525"  
  instance_type               = "t3a.small"
  key_name                    = var.ec2_key_name  
  availability_zone           = "us-gov-west-1a"
  depends_on                  = ["aws_internet_gateway.sslo-lab-igw"]
  tags = {
    Name = "sslo-lab-web-server"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-webserver.id}"
    device_index              = 0
  }
}

###########################
# Palo ALto Configs Begin #
###########################

#
# Create Inspection Subnet out from BIG-IP to Palo 10.0.5.0/25
#
resource "aws_subnet" "inspection_out" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.5.0/25"
  availability_zone     = "us-gov-west-1a"
  tags = {
    Name = "sslo-lab-inspection-out"
    Group_Name = "sslo-lab-inspection-out"
  }
}

#
# Create Inspection Subnet in from Palo to BIG-IP 10.0.5.128/25
#
resource "aws_subnet" "inspection_in" {
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.5.128/25"
  availability_zone     = "us-gov-west-1a"
  tags = {
    Name = "sslo-lab-inspection-in"
    Group_Name = "sslo-lab-inspection-in"
  }
}

#
# Create External(MGMT) Network Interface for Firewall
#
resource "aws_network_interface" "sslo-lab-firewall-mgmt" {
  subnet_id             = "${aws_subnet.jumpbox.id}"
  security_groups       = ["${aws_security_group.jumpbox_to_mgmt.id}"]
  tags = {
    Name = "sslo-lab-firewall-mgmt"
  }
}

#
# Create Inspection Zone Network Interface from BIGIP to Firewall
#
resource "aws_network_interface" "sslo-lab-firewall-inspection-in" {
  subnet_id             = "${aws_subnet.inspection_out.id}"
  security_groups       = ["${aws_security_group.inspection_zone.id}"]
  tags = {
    Name = "sslo-lab-firewall-firewall-inspection-in"
  }
}

#
# Create Inspection Zone Network Interface from Palo to BIG-IP
#
resource "aws_network_interface" "sslo-lab-firewall-inspection-out" {
  subnet_id             = "${aws_subnet.inspection_in.id}"
  security_groups       = ["${aws_security_group.inspection_zone.id}"]
  tags = {
    Name = "sslo-lab-firewall-firewall-inspection-out"
  }
}

#
# Create Security Group for Inspection Zone
#
resource "aws_security_group" "inspection_zone" {
  vpc_id                = module.vpc.vpc_id
  description           = "sslo-lab-sg-inspection_zone"
  name                  = "sslo-lab-sg-inspection_zone"
  tags = {
    Name = "sslo-lab-sg-inspection_zone"
  }
  ingress {
    # SSH (change to whatever ports you need)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#
# Create Firewall - Palo Alto
# 
resource "aws_instance" "firewall" {

  count                       = 1
  ami                         = "ami-15547074"  
  instance_type               = "m4.xlarge"
  key_name                    = var.ec2_key_name  
  availability_zone           = "us-gov-west-1a"
  depends_on                  = ["aws_internet_gateway.sslo-lab-igw"]
  tags = {
    Name = "sslo-lab-firewall"
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-firewall-mgmt.id}"
    device_index              = 0
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-firewall-inspection-in.id}"
    device_index              = 1
  }
  network_interface {
    network_interface_id      = "${aws_network_interface.sslo-lab-firewall-inspection-out.id}"
    device_index              = 2
  }
}

#############
# Variables #
#############

#
# Variables used by this example
#
locals {
  prefix            = "tf-aws-sslo-lab"
  region            = "us-gov-west-1"
  azs               = "us-gov-west-1a"
  cidr              = "10.0.0.0/16"
  allowed_mgmt_cidr = "0.0.0.0/0"
  allowed_app_cidr  = "0.0.0.0/0"
}
