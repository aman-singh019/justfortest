module "scr01_vm" {
  source = "./Virtual_Machine"
  vm_configurations    = var.vm_configurations
  vmUserName           = var.vmUserName
  vmimage              = var.vmimage
  storage_account_type = var.storage_account_type
}