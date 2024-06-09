variable "os_image_worker" {
  type    = string
  default = "ubuntu-2004-lts"
}

data "yandex_compute_image" "ubuntu-worker" {
  family = var.os_image_worker
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "worker_resources" {
  type = object({
    cpu         = number
    ram         = number
    disk        = number
    core_fraction = number
    platform_id = string
  })
  default = {
    cpu         = 4
    ram         = 8
    disk        = 10
    core_fraction = 10
    platform_id = "standard-v1"
  }
}

resource "yandex_compute_instance" "worker" {
  depends_on = [yandex_compute_instance.master]
  count      = var.worker_count
  allow_stopping_for_update = true
  name          = "worker-${count.index + 1}"
  platform_id   = var.worker_resources.platform_id
  zone = var.zone2
  resources {
    cores         = var.worker_resources.cpu
    memory        = var.worker_resources.ram
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-worker.image_id
      size     = var.worker_resources.disk
    }
  }

  metadata = {
    ssh-keys           = "ubuntu:${local.ssh-keys}"
    serial-port-enable = "1"
    user-data          = data.template_file.cloudinit.rendered
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.diplom-subnet2.id
    nat                = true
  }

  scheduling_policy {
    preemptible = true
  }
}