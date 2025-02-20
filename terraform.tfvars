vm_configurations = [
  {
    name             = "wink-dev-can-central-scr01-test"
    ip_address       = "10.0.0.5"
    data_disks_count = 1
    data_disk_size   = 1024
    vm_rg            = "vm0101-rg"
    vnet_name        = "vnetxyz"
    vnet_rg          = "wink-deploy"
    subnet_name      = "default"
    vm_Size          = "Standard_B2ms"
    os_disk_size     = 64
    location         = "canada central"
  }
]

vmimage = {
  "publisher" = "RedHat"
  "offer"     = "RHEL"
  "sku"       = "91-gen2"
  "version"   = "latest"
}

KeyVaultName = "kv12345wnk"

storage_account_type = "Premium_LRS"

vmUserName = "azadmin"

kv_rg = "wink-test-vm"
