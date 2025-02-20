
variable "vm_configurations" {
  description = "The name of the VM that will be created"
  type = list(object({
    name             = string
    ip_address       = string
    data_disks_count = number
    data_disk_size   = number
    vm_rg            = string
    vnet_name        = string
    vnet_rg          = string
    subnet_name      = string
    vm_Size          = string
    os_disk_size     = number
    location         = string

  }))

}

variable "vmUserName" {
  description = "The VM User Name"
  type        = string
}

variable "vmimage" {
  description = "Vm image config"
  type        = map(string)

}

# variable "KeyVaultName" {
#   description = "name of the already existing key vault"
#   type        = string
# }

variable "storage_account_type" {
  description = " os disk storage account type"
  type        = string
}

# variable "kv_rg" {
#   description = "key vault resource group name"
#   type        = string
# }

