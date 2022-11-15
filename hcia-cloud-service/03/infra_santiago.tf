resource "huaweicloud_vpc" "vpc_1_san" {
  name = "vpc-1-hcia03"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet_1_1_san" {
  name       = "subnet-1-1-hcia03"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id     = huaweicloud_vpc.vpc_1_san.id
}

resource "huaweicloud_vpc_subnet" "subnet_1_2_san" {
  name       = "subnet-1-2-hcia03"
  cidr       = "192.168.1.0/24"
  gateway_ip = "192.168.1.1"
  vpc_id     = huaweicloud_vpc.vpc_1_san.id
}

resource "huaweicloud_vpc" "vpc_2_san" {
  name = "vpc-2-hcia03"
  cidr = "10.0.0.0/16"
}

resource "huaweicloud_vpc_subnet" "subnet_2_1_san" {
  name       = "subnet-2-1-hcia03"
  cidr       = "10.0.0.0/24"
  gateway_ip = "10.0.0.1"
  vpc_id     = huaweicloud_vpc.vpc_2_san.id
}

resource "huaweicloud_networking_secgroup" "secgroup_san" {
  name        = "secgroup-hcia03"
  description = "My security group"
}

resource "huaweicloud_networking_secgroup_rule" "secgroup_rule_san" {
  security_group_id = huaweicloud_networking_secgroup.secgroup_san.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8889
  port_range_max    = 8889
  remote_ip_prefix  = "0.0.0.0/0"
}

data "huaweicloud_availability_zones" "az_san" {}

data "huaweicloud_compute_flavors" "flavor_san" {
  availability_zone = data.huaweicloud_availability_zones.az_san.names[0]
  performance_type  = "normal"
  cpu_core_count    = 1
  memory_size       = 1
}

data "huaweicloud_images_image" "centos_san" {
  os_version   = "CentOS 7.9 64bit"
  architecture = "x86"
  visibility   = "public"
  most_recent  = true
}

resource "huaweicloud_compute_instance" "ecs_1_1_san" {
  name               = "ecs-1-1-hcia03"
  image_id           = data.huaweicloud_images_image.centos_san.id
  flavor_id          = data.huaweicloud_compute_flavors.flavor_san.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup_san.id]
  availability_zone  = data.huaweicloud_availability_zones.az_san.names[0]
  admin_pass         = "Huawei@1234"

  network {
    uuid = huaweicloud_vpc_subnet.subnet_1_1_san.id
    fixed_ip_v4 = "192.168.0.11"
  }
}

resource "huaweicloud_compute_instance" "ecs_1_2_san" {
  name               = "ecs-1-2-hcia03"
  image_id           = data.huaweicloud_images_image.centos_san.id
  flavor_id          = data.huaweicloud_compute_flavors.flavor_san.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup_san.id]
  availability_zone  = data.huaweicloud_availability_zones.az_san.names[0]
  admin_pass         = "Huawei@1234"

  network {
    uuid = huaweicloud_vpc_subnet.subnet_1_2_san.id
    fixed_ip_v4 = "192.168.1.12"
  }
}

resource "huaweicloud_compute_instance" "ecs_2_1_san" {
  name               = "ecs-2-1-hcia03"
  image_id           = data.huaweicloud_images_image.centos_san.id
  flavor_id          = data.huaweicloud_compute_flavors.flavor_san.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.secgroup_san.id]
  availability_zone  = data.huaweicloud_availability_zones.az_san.names[0]
  admin_pass         = "Huawei@1234"

  network {
    uuid = huaweicloud_vpc_subnet.subnet_2_1_san.id
    fixed_ip_v4 = "10.0.0.21"
  }
}

resource "huaweicloud_lb_loadbalancer" "elb" {
  name = "elb-hcia03"
  vip_subnet_id = huaweicloud_vpc_subnet.subnet_1_1_san.ipv4_subnet_id
}

resource "huaweicloud_vpc_eip" "eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type  = "PER"
    name        = "bandw-hcia03"
    size        = 1
    charge_mode = "traffic"
  }
}

resource "huaweicloud_vpc_eip_associate" "eip_elb" {
  public_ip = huaweicloud_vpc_eip.eip.address
  port_id   = huaweicloud_lb_loadbalancer.elb.vip_port_id
}

resource "huaweicloud_lb_listener" "elb_listener" {
  protocol        = "HTTP"
  protocol_port   = 8889
  loadbalancer_id = huaweicloud_lb_loadbalancer.elb.id
}

resource "huaweicloud_lb_pool" "pool_1" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = huaweicloud_lb_listener.elb_listener.id
}

resource "huaweicloud_lb_member" "member_1" {
  address       = huaweicloud_compute_instance.ecs_1_1_san.access_ip_v4
  protocol_port = 8889
  pool_id       = huaweicloud_lb_pool.pool_1.id
  subnet_id     = huaweicloud_vpc_subnet.subnet_1_1_san.ipv4_subnet_id
}

resource "huaweicloud_lb_member" "member_2" {
  address       = huaweicloud_compute_instance.ecs_1_2_san.access_ip_v4
  protocol_port = 8889
  pool_id       = huaweicloud_lb_pool.pool_1.id
  subnet_id     = huaweicloud_vpc_subnet.subnet_1_2_san.ipv4_subnet_id
}
