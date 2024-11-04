# * This module will create 1 Compute Instances, with a reserved public IP
module "instance" {
  source = "./modules/instance"
  # general oci parameters
  compartment_ocid = var.compartment_ocid
  freeform_tags    = var.freeform_tags
  defined_tags     = var.defined_tags
  # compute instance parameters
  ad_number                   = 3
  instance_count              = 1
  instance_display_name       = var.instance_display_name
  instance_state              = var.instance_state
  shape                       = var.shape
  source_ocid                 = var.source_ocid
  source_type                 = var.source_type
  instance_flex_memory_in_gbs = 1
  instance_flex_ocpus         = 1
  # operating system parameters
  ssh_public_keys = file(var.ssh_public_keys)
  # networking parameters
  public_ip    = var.public_ip # NONE, RESERVED or EPHEMERAL
  subnet_ocids = var.subnet_ocids
  # storage parameters
  boot_volume_backup_policy  = var.boot_volume_backup_policy
  block_storage_sizes_in_gbs = [] # no block volume will be created
  preserve_boot_volume       = false
}

module "provisioner" {
  depends_on     = [module.instance.instance]
  source         = "./modules/provisioner"
  instance_ip    = module.instance.public_ip[0]
  user           = var.user
  privatekeypath = "c:/Users/dazma/.ssh/id_rsa"
  wg_host        = var.wg_host
  wg_password    = var.wg_password
}
