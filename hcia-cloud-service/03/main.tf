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
