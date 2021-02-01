provider "vsphere" {
  user           = "${var.user_name}"
  password       = "${var.password}"
  vsphere_server = "${var.server}"
  version = "< 1.16.0"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}
#### RETRIEVE DATA INFORMATION ON VCENTER ####
data "vsphere_datacenter" "dc" {
  name = "devcloud"
}
data "vsphere_resource_pool" "pool" {
  name          = "fenrir/Resources"
 datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "vmstore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "portGroup-1004"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu16"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
#### VM CREATION ####
# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  name                 = "icheck"
  num_cpus             = 2
  memory               = 4096
  datastore_id         = "${data.vsphere_datastore.datastore.id}"
  #host_system_id       = "${data.vsphere_host.host.id}"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"
  folder            = "dev_zone"
  # Set network parameters
  network_interface {
    network_id         = "${data.vsphere_network.network.id}"
  }
  # Use a predefined vmware template has main disk
  disk {
    label = "vm-two.vmdk"
    size = "30"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    customize {
      linux_options {
        host_name = "vm-two"
        domain    = "test.internal"
      }
     
    }
  }
}
