###############################################
###          create ec2 resources           ###
###############################################

# get current region from provider
data "aws_region" "current" {
  current = true
}
# ${data.aws_region.current.name}
# create a security group for the elb
resource "aws_security_group" "elb_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "elb-securitygroup"
  description = "security group for a load balancer"
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = "${var.elb_port}"
      to_port     = "${var.elb_port}"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "elb-sg"
  }
}

# create a security group for the instances
resource "aws_security_group" "instance_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "instance-securitygroup"
  description = "security group for an instance"
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port       = "${var.instance_port}"
      to_port         = "${var.instance_port}"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb_sg.id}"]
  }

  tags {
    Name = "instance-sg"
  }
}

# create instance(s)
resource "aws_instance" "instance" {
  count                  = "${var.instances_count}"
  ami                    = "${var.ami}"
  instance_type          = "${var.intance_type}"
  subnet_id              = "${var.subnet}"
  vpc_security_group_ids = ["${aws_security_group.instance_sg.id}"]
  key_name               = "${var.keypair}"
  tags {
    Name = "${var.vpc_name}-${var.instance_name}-${count.index + 1}"
  }

  # upload the install.sh file to tmp
  provisioner "file" {
    source      = "install.sh"
    destination = "/tmp/install.sh"
    connection {
      user        = "ubuntu"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  # execute the file with the node index
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh ${count.index + 1}",
    ]
    connection {
      user        = "ubuntu"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
}

# create elb and attach the provisioned instances
resource "aws_elb" "elb" {
  name                        = "${var.vpc_name}-${var.elb_name}"
  subnets                     = ["${var.subnet}"]
  security_groups             = ["${aws_security_group.elb_sg.id}"]
  instances                   = ["${distinct(compact(aws_instance.instance.*.id))}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = "${var.instance_port}"
    instance_protocol = "http"
    lb_port           = "${var.elb_port}"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.instance_port}/"
    interval            = 10
  }

  tags {
    Name = "${var.elb_name}"
  }
}


