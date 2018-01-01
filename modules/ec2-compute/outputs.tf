output "instance_id" {
  value = "${aws_instance.instance.0.id}"
}

output "ELB_Name" {
  value = "${aws_elb.elb.dns_name}"
}

output "Instances_IPs" {
    value = "${join(",", aws_instance.instance.*.public_ip)}"
}

