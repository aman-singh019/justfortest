module "scr01_vm" {
  source = "./Virtual_Machine"
  kv_rg                = var.kv_rg
  vm_configurations    = var.vm_configurations
  vmUserName           = var.vmUserName
  vmimage              = var.vmimage
  KeyVaultName         = var.KeyVaultName
  storage_account_type = var.storage_account_type
}