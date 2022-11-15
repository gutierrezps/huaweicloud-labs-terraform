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

resource "huaweicloud_vpc" "vpc02" {
  name = "vpc-hcia02"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet02" {
  name       = "subnet-hcia02"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id     = huaweicloud_vpc.vpc02.id
}

resource "huaweicloud_networking_secgroup" "secgroup" {
  name        = "secgroup-hcia02"
  description = "My security group"
}

data "huaweicloud_availability_zones" "myaz" {}

data "huaweicloud_compute_flavors" "myflavor" {
  availability_zone = data.huaweicloud_availability_zones.myaz.names[0]
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 2
}

data "huaweicloud_images_image" "centos" {
  # for some reason, can't create ECS with CentOS 8.2
  os_version   = "CentOS 7.9 64bit"
  architecture = "x86"
  visibility   = "public"
  most_recent  = true
}

resource "huaweicloud_compute_instance" "ecs" {
  name               = "ecs-hcia02"
  image_id           = data.huaweicloud_images_image.centos.id
  flavor_id          = data.huaweicloud_compute_flavors.myflavor.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup.id]
  availability_zone  = data.huaweicloud_availability_zones.myaz.names[0]
  admin_pass         = "Huawei@1234"

  network {
    uuid = huaweicloud_vpc_subnet.subnet02.id
  }
}

resource "huaweicloud_images_image" "ecs_img" {
  name        = "ecs-hcia02-img"
  instance_id = huaweicloud_compute_instance.ecs.id
  description = "created by Terraform"

  tags = {
    foo = "bar"
    key = "value"
  }
}

resource "huaweicloud_as_configuration" "as_config" {
  scaling_configuration_name = "as-config-hcia02"

  instance_config {
    flavor = "s3.small.1"
    image  = huaweicloud_images_image.ecs_img.id
    key_name = "test-keypair"

    disk {
      size        = 40
      volume_type = "SAS"
      disk_type   = "SYS"
    }
  }
}

resource "huaweicloud_as_group" "as_group" {
  scaling_group_name       = "as-group-hcia02"
  scaling_configuration_id = huaweicloud_as_configuration.as_config.id
  desire_instance_number   = 2
  min_instance_number      = 1
  max_instance_number      = 5
  vpc_id                   = huaweicloud_vpc.vpc02.id
  delete_publicip          = true
  delete_instances         = "yes"
  force_delete             = true

  networks {
    id = huaweicloud_vpc_subnet.subnet02.id
  }
  security_groups {
    id = huaweicloud_networking_secgroup.secgroup.id
  }
}

resource "huaweicloud_as_policy" "as_policy_up" {
  scaling_policy_name = "as-policy-up-hcia02"
  scaling_policy_type = "RECURRENCE"
  scaling_group_id    = huaweicloud_as_group.as_group.id
  cool_down_time      = 900

  scaling_policy_action {
    operation       = "ADD"
    instance_number = 1
  }
  scheduled_policy {
    launch_time     = "18:00"
    recurrence_type = "Daily"
    end_time        = "2022-12-22T19:00Z"
  }
}

resource "huaweicloud_as_policy" "as_policy_down" {
  scaling_policy_name = "as-policy-down-hcia02"
  scaling_policy_type = "RECURRENCE"
  scaling_group_id    = huaweicloud_as_group.as_group.id
  cool_down_time      = 900

  scaling_policy_action {
    operation       = "REMOVE"
    instance_number = 1
  }
  scheduled_policy {
    launch_time     = "23:00"
    recurrence_type = "Daily"
    end_time        = "2022-12-22T23:30Z"
  }
}
