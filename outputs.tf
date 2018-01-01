

output "ELB_Name_first_region" {
  value = "${module.first_stack.ELB_Name}"
}

output "Instances_IP_first_region" {
    value = "${module.first_stack.Instances_IPs}"
}

output "ELB_Name_second_region" {
  value = "${module.second_stack.ELB_Name}"
}

output "Instances_IP_second_region" {
    value = "${module.second_stack.Instances_IPs}"
}
