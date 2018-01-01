

# This main conf file creates the following resources in AWS:
# - 2 VPCs - one in us-west-2, and the second in us-east-1
# - 2 stacks of ELB + backend instances (including SG for both)
# - AMI for each region

# it's best to use the run_terraform.sh wrapper in order to run this conf
# since a couple of TF commands are required to be executed + creation of keypair files

###############################################
###                main                     ###
###############################################

# create the first vpc
module "first_vpc" {
  source    = "modules/vpc/"
  name      = "first_vpc"
  providers = {
    aws = "aws.west"
  }
}

# create the second vpc
module "second_vpc" {
  source    = "modules/vpc/"
  name      = "second_vpc"
  providers = {
    aws = "aws.east"
  }
}

# create keypair for west region
resource "aws_key_pair" "first_keypair" {
  provider   = "aws.west"
  key_name   = "${var.private_key_path}"
  public_key = "${file("${var.public_key_path}")}"
  lifecycle {
    ignore_changes = ["public_key"]
  }
}

# create keypair for east region
resource "aws_key_pair" "second_keypair" {
  provider   = "aws.east"
  key_name   = "${var.private_key_path}"
  public_key = "${file("${var.public_key_path}")}"
  lifecycle {
    ignore_changes = ["public_key"]
  }
}

# deploy the first stack
module "first_stack" {
  source           = "modules/ec2-compute/"
  ami              = "ami-06b94666"
  vpc_name         = "first-vpc"
  vpc_id           = "${module.first_vpc.vpc_id}"
  subnet           = "${module.first_vpc.subnet_id}"
  keypair          = "${aws_key_pair.first_keypair.key_name}"
  private_key_path = "${var.private_key_path}"
  public_key_path  = "${var.public_key_path}"
  providers = {
    aws = "aws.west"
  }
}

# take an AMI snapthot of instance 1 form the first stack
resource "aws_ami_from_instance" "instance_ami" {
  provider           = "aws.west"
  name               = "first-ami"
  description        = "An ami from ${module.first_stack.instance_id}"
  source_instance_id = "${module.first_stack.instance_id}"
}

# copy the ami to the second region
resource "aws_ami_copy" "ami_copy" {
  provider           = "aws.east"
  name               = "second-ami"
  description        = "A copy of ${aws_ami_from_instance.instance_ami.id} from region ${var.first_region}"
  source_ami_id      = "${aws_ami_from_instance.instance_ami.0.id}"
  source_ami_region  = "${var.first_region}"
}

# deploy the second stack
module "second_stack" {
  source           = "modules/ec2-compute/"
  ami              = "${aws_ami_copy.ami_copy.0.id}"
  vpc_name         = "second-vpc"
  vpc_id           = "${module.second_vpc.vpc_id}"
  subnet           = "${module.second_vpc.subnet_id}"
  keypair          = "${aws_key_pair.second_keypair.key_name}"
  private_key_path = "${var.private_key_path}"
  public_key_path  = "${var.public_key_path}"
  providers = {
    aws = "aws.east"
  }
}
