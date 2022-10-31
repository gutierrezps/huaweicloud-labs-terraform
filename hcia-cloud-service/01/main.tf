terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.42.0"
    }
  }
}

# AK, SK and Region configured as environment variables (run config.ps1)
provider "huaweicloud" {}

resource "huaweicloud_vpc" "vpc01" {
  name = "vpc-hcia-01"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet01" {
  name       = "subnet-hcia-01"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id     = huaweicloud_vpc.vpc01.id
}
