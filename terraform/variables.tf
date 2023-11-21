variable "vm_name" {
    type = string
    description = "Имя виртуальной машины"
}

variable "vm_count" {
    type = number
    description = "Количество создаваемых виртуальных машин"
}

variable "vm_subnet" {
    type = string
    description = "Имя локальной подсети для расположения виртуальной машины"
}

variable "vm_sec" {
    type = string
    description = "Имя группы безопасности для виртуальной машины"
}

variable "vm_network" {
    type = string
    description = "Имя виртуальной сети"
}

variable "dns_zone" {
    type = string
    description = "Имя DNS-зоны"
}

variable "X" {
    type = number
    description = "Номер рабочего места"
}

variable "service_account_key_file" {
    type = string
    description = "authorized_key.json"
    default = "../authorized_key.json"
}

variable "cloud_id" {
    type = string
    description = "Yandex Cloud ID"
}

variable "folder_id" {
    type = string
    description = "Yandex Cloud Folder ID"
}