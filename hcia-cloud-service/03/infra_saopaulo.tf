resource "huaweicloud_vpc" "vpc_3_sp" {
  name = "vpc-3-hcia03"
  cidr = "172.16.0.0/16"
  region = "sa-brazil-1"
}

resource "huaweicloud_vpc_subnet" "subnet_3_1_sp" {
  name       = "subnet-3-1-hcia03"
  cidr       = "172.16.0.0/24"
  gateway_ip = "172.16.0.1"
  vpc_id     = huaweicloud_vpc.vpc_3_sp.id
  region = "sa-brazil-1"
}

resource "huaweicloud_networking_secgroup" "secgroup_sp" {
  name        = "secgroup-hcia03"
  description = "My security group"
  region = "sa-brazil-1"
}

data "huaweicloud_availability_zones" "az_sp" {
    region = "sa-brazil-1"
}

data "huaweicloud_compute_flavors" "flavor_sp" {
  availability_zone = data.huaweicloud_availability_zones.az_sp.names[0]
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 2
  region = "sa-brazil-1"
}

data "huaweicloud_images_image" "centos_sp" {
  os_version   = "CentOS 7.9 64bit"
  architecture = "x86"
  visibility   = "public"
  most_recent  = true
  region = "sa-brazil-1"
}

resource "huaweicloud_compute_instance" "ecs_3_1_sp" {
  name               = "ecs-3-1-hcia03"
  image_id           = data.huaweicloud_images_image.centos_sp.id
  flavor_id          = data.huaweicloud_compute_flavors.flavor_sp.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup_sp.id]
  availability_zone  = data.huaweicloud_availability_zones.az_sp.names[0]
  admin_pass         = "Huawei@1234"
  region = "sa-brazil-1"

  network {
    uuid = huaweicloud_vpc_subnet.subnet_3_1_sp.id
    fixed_ip_v4 = "172.16.0.31"
  }
}
