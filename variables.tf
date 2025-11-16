# provider identity parameters

variable "fingerprint" {
  type        = string
  description = "Fingerprint of OCI API private key"
}

variable "private_key_path" {
  type        = string
  description = "Path to OCI API private key used"
}

variable "region" {
  type        = string
  description = "The OCI region where resources will be created"
  # List of regions: https://docs.cloud.oracle.com/iaas/Content/General/Concepts/regions.htm#ServiceAvailabilityAcrossRegions
}

variable "tenancy_ocid" {
  type        = string
  description = "Tenancy OCID where to create the sources"
}

variable "user_ocid" {
  type        = string
  description = "OCID of user that terraform will use to create the resources"
}

# general oci parameters

variable "compartment_ocid" {
  type        = string
  description = "Compartment OCID where to create all resources"
}

variable "freeform_tags" {
  type        = map(string)
  description = "Simple key-value pairs to tag the resources created using freeform tags"
  default     = null
}

variable "defined_tags" {
  type        = map(string)
  description = "Predefined and scoped to a namespace to tag the resources created using defined tags"
  default     = null
}

# compute instance parameters

variable "instance_ad_number" {
  type        = number
  description = "The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin"
  default     = 1
}

variable "instance_fd_number" {
  type        = number
  description = "The fault domain number of the instance (1, 2, or 3). If none is provided, OCI will automatically assign a fault domain"
  default     = null

  validation {
    condition     = var.instance_fd_number == null || (var.instance_fd_number >= 1 && var.instance_fd_number <= 3)
    error_message = "Fault domain number must be between 1 and 3, or null for automatic assignment"
  }
}

variable "instance_count" {
  type        = number
  description = "Number of identical instances to launch from a single module"
  default     = 1
}

variable "instance_display_name" {
  type        = string
  description = "(Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable"
  default     = "module_instance_flex"
}

variable "instance_flex_memory_in_gbs" {
  type        = number
  description = "(Updatable) The total amount of memory available to the instance, in gigabytes"
  default     = null
}

variable "instance_flex_ocpus" {
  type        = number
  description = "(Updatable) The total number of OCPUs available to the instance"
  default     = null
}

variable "instance_state" {
  type        = string
  description = "(Updatable) The target state for the instance. Could be set to RUNNING or STOPPED"
  default     = "RUNNING"

  validation {
    condition     = contains(["RUNNING", "STOPPED"], var.instance_state)
    error_message = "Accepted values are RUNNING or STOPPED."
  }
}

variable "shape" {
  type        = string
  description = "The shape of an instance"
  default     = null
}

variable "source_ocid" {
  type        = string
  description = "The OCID of an image or a boot volume to use, depending on the value of source_type"
}

variable "source_type" {
  type        = string
  description = "The source type for the instance"
  default     = "image"
}

# operating system parameters

variable "ssh_public_keys" {
  type        = string
  description = "Public SSH keys to be included in the ~/.ssh/authorized_keys file for the default user on the instance. To provide multiple keys, see docs/instance_ssh_keys.adoc"
  default     = null
}

# networking parameters

variable "public_ip" {
  type        = string
  description = "Whether to create a Public IP to attach to primary vnic and which lifetime. Valid values are NONE, RESERVED or EPHEMERAL"
  default     = "RESERVED"
}

variable "subnet_ocids" {
  type        = list(string)
  description = "The unique identifiers (OCIDs) of the subnets in which the instance primary VNICs are created"
}

# storage parameters

variable "boot_volume_backup_policy" {
  type        = string
  description = "Choose between default backup policies: gold, silver, bronze. Use disabled to affect no backup policy on the Boot Volume"
  default     = "disabled"
}

variable "block_storage_sizes_in_gbs" {
  type        = list(string)
  description = "Sizes of volumes to create and attach to each instance"
  default     = [50]
}

# provisioning parameters

variable "user" {
  type        = string
  description = "The user to connect to the instance"
}

variable "wg_host" {
  type        = string
  description = "The hostname of the WireGuard server"
}

variable "wg_password" {
  type        = string
  description = "The password of the WireGuard server"
  sensitive   = true
}

variable "privatekeypath" {
  type        = string
  description = "Path to private SSH key file (id_rsa)"
}

variable "cron_restart_schedule" {
  type        = string
  description = "Cron schedule for container restart (default: daily at 3 AM)"
  default     = "0 3 * * *"
}

variable "enable_wg_configs" {
  type        = bool
  description = "Enable WireGuard configuration files backup/restore"
  default     = false
}

variable "backup_path" {
  type        = string
  description = "Path to backup directory"
  default     = "./modules/backup/wg_backup"
}
