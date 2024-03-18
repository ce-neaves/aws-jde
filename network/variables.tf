variable "vpc_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "vpc_name" {
  default = "vpc01"
}

variable "vpc_cidr" {
  default = "172.20.0.0/16"
}

variable "subnetAZ1_public_cidr" {
  default = "172.20.0.0/24"
}

variable "subnetAZ2_public_cidr" {
  default = "172.20.1.0/24"
}

variable "subnetAZ1_private_cidr" {
  default = "172.20.10.0/24"
}

variable "subnetAZ2_private_cidr" {
  default = "172.20.11.0/24"
}

variable "subnetAZ1_private_data_cidr" {
  default = "172.20.20.0/24"
}

variable "subnetAZ2_private_data_cidr" {
  default = "172.20.21.0/24"
}

variable "create_NATgws" {
  default = 1
}
