# Huawei Cloud Labs using Terraform

This repository contains Terraform configuration files for the HCIA
Cloud Service Lab Guides. They were developed as part of self-learning
Terraform.

[HuaweiCloud Provider Docs][provider-docs]

[HuaweiCloud Provider repository][provider-repo]

## Setup and execution

1. Clone this repository;
2. Make a copy of `config.example.ps1` named `config.ps1`, edit it and put
   the AK/SK of your account;
3. `cd` into the lab directory (e.g. `cd hcia-cloud-service/01`)
4. `terraform init`
5. `terraformm apply`
6. When finished, `terraform destroy`

## Resources used

### HCIA Cloud Service

- 01: VPC and subnet

[provider-docs]: <https://registry.terraform.io/providers/huaweicloud/huaweicloud/latest/docs>
[provider-repo]: <https://github.com/huaweicloud/terraform-provider-huaweicloud>
