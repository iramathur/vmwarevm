provider "vsphere" {
  user           = "cmpqa.svc@itomcmp.servicenow.com"
  password       = "snc!23$"
  vsphere_server = "10.198.1.13"
  version = "~> 1.16.0"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
resource "random_id" "server" {
  byte_length = 8
}


data "vsphere_datacenter" "dc" {
  name = "devcloud"
}

resource "vsphere_folder" "foldervm" {
  path          = "terrtar-testng${random_id.server.hex}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}


data "vsphere_datastore" "datastore" {
  name          = "vmstore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "fenrir/Resources"
 datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "ubuntu16"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_tag_category" "category" {
  name = "Dev_lab"
}
data "vsphere_tag" "tag" {
  name        = "Dev_app"
  category_id = "${data.vsphere_tag_category.category.id}"
}
data "vsphere_network" "network" {
  name          = "portGroup-1004"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "trial-vm${random_id.server.hex}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder = "${vsphere_folder.foldervm.path}"
  tags = ["${data.vsphere_tag.tag.id}"]
  num_cpus = 1
  memory   = 512
  guest_id = "centos64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  wait_for_guest_net_timeout = 0

  disk {
    label = "disk0"
    size  = 4
  }
}
