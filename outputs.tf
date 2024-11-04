output "instance" {
  description = "IP information of the instances provisioned by this module."
  value       = module.instance.instances_summary
}
