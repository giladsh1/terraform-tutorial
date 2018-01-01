variable "ami" {}
variable "vpc_name" {}
variable "vpc_id" {}
variable "subnet" {}
variable "keypair" {}
variable "private_key_path" {}
variable "public_key_path" {}
variable "intance_type" { default = "t2.micro" }
variable "instances_count" { default = "2" }
variable "instance_port" { default = "8080" }
variable "elb_port" { default = "80" }
variable "elb_name" { default = "test-elb" }
variable "instance_name" { default = "test-instance" }
