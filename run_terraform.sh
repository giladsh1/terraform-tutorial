#!/bin/bash

# This is a simple wrapper in order to run Terraform
# Please supply plan / apply or destroy as a first input

# create a keypair with ssh-keygen
test -f keypair || cat /dev/zero | ssh-keygen -f keypair -q -N ""

# check the TF command - only plan / apply / destroy is valid
command=$1
err_message="\nERROR - unknown terraform command!\nPlease supply plan, apply or destroy only.\n"
[ -z "$command" ] && echo -e "$err_message" && exit 1
[ "$command" != "plan" ] && [ "$command" != "apply" ] && [ "$command" != "destroy" ]&& echo -e "$err_message" && exit 1

# run TF
terraform init 2>&1 > /dev/null
[ "$command" == "plan" ] && terraform plan
[ "$command" == "apply" ] && terraform apply -auto-approve
[ "$command" == "destroy" ] && terraform destroy -force
