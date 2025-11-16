# * This module will create 1 Compute Instances, with a reserved public IP
module "instance" {
  source = "./modules/instance"
  # general oci parameters
  compartment_ocid = var.compartment_ocid
  freeform_tags    = var.freeform_tags
  defined_tags     = var.defined_tags
  # compute instance parameters
  ad_number                   = 3
  fd_number                   = var.instance_fd_number
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

# IMPORTANT: If instance needs to be recreated, run backup first:
# terraform apply -target="module.backup"
# This ensures backup runs BEFORE instance destruction
module "backup" {
  source         = "./modules/backup"
  instance_id    = module.instance.instance_id[0]
  instance_ip    = module.instance.public_ip[0]
  user           = var.user
  privatekeypath = var.privatekeypath
  backup_path    = var.backup_path
}

module "provisioner" {
  depends_on            = [module.instance.instance_id, module.backup]
  source                = "./modules/provisioner"
  instance_ip           = module.instance.public_ip[0]
  user                  = var.user
  privatekeypath        = var.privatekeypath
  wg_host               = var.wg_host
  wg_password           = var.wg_password
  cron_restart_schedule = var.cron_restart_schedule
  enable_wg_configs     = var.enable_wg_configs
}
