terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

resource "yandex_vpc_network" "my_vnet" {
  name = var.vm_network
}

resource "yandex_vpc_subnet" "my_subnet" {
  name           = var.vm_subnet
  network_id = yandex_vpc_network.my_vnet.id
  v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_vpc_security_group" "my_sec_group" {
  name        = var.vm_sec
  network_id = yandex_vpc_network.my_vnet.id
  description = "Security group for my VM"

  ingress {
    protocol       = "TCP"
    port           = 22
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 443
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }

  egress {
    protocol       = "TCP"
    port           = 22
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }

  egress {
    protocol       = "TCP"
    port           = 80
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }

  egress {
    protocol       = "TCP"
    port           = 443
	v4_cidr_blocks = ["192.168.${var.X}0.0/24"]
  }
}

resource "yandex_compute_instance_group" "instances_group" {
  name = var.vm_name

  folder_id          = var.folder_id
  service_account_id = jsondecode(file(var.service_account_key_file)).service_account_id

  instance_template {
    name = "${var.vm_name}{instance.index}"

    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        size     = 10
        image_id = "fd8pnse1rshdvced0u8h"
      }
    }

    metadata = {
      ssh-keys = "ansible:${file("../id_rsa_reaDist.pub")}"
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.my_subnet.id]
      nat        = true
    }
  }

  scale_policy {
    fixed_scale {
      size = var.vm_count
    }
  }

  deploy_policy {
    max_unavailable = var.vm_count
    max_expansion   = 0
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }
}

# dns
data "yandex_dns_zone" "my_dns_zone" {
  dns_zone_id = var.dns_zone
}

resource "yandex_dns_recordset" "dns_record" {
  zone_id = data.yandex_dns_zone.my_dns_zone.id
  name    = "www.comp${var.X}.hackatom.ru"
  type    = "A"
  ttl     = 300
  data    = [yandex_compute_instance_group.instances_group.instances.0.network_interface.0.nat_ip_address]
}

# ansible
resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
	  vm_name = var.vm_name,
      vm_instances = yandex_compute_instance_group.instances_group.instances,
    }
  )
  filename = "../ansible/inventory"
}