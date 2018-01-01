## terraform config

This TF config creates the following resources in AWS:
  - 2 VPCs - one in us-west-2, and the second in us-east-1
  - 2 stacks of ELB + backend instances (including SG for both)
  - AMI for each region

in order to use this Terraform config, please run -  

`./run_terraform.sh <plan / apply / destroy>`
