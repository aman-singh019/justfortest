
locals {
  datadisk_objects = flatten([
    for idx, config in var.vm_configurations : [
      for i in range(config.data_disks_count) : {
        vm_index       = idx
        vm_name        = config.name
        ip_address     = config.ip_address
        datadisk_name  = "${config.name}-datadisk${i + 1}"
        lun            = "${i + 1}"
        data_disk_size = config.data_disk_size
        rg_name        = config.vm_rg
        location       = config.location

      }
    ]
  ])
}

data "azurerm_resource_group" "vm_rg" {
  count = length(var.vm_configurations)
  name  = var.vm_configurations[count.index]["vm_rg"]
}

data "azurerm_virtual_network" "vnet" {
  count               = length(var.vm_configurations)
  name                = var.vm_configurations[count.index]["vnet_name"]
  resource_group_name = var.vm_configurations[count.index]["vnet_rg"]
}

data "azurerm_subnet" "vmsubnet" {
  count                = length(var.vm_configurations)
  name                 = var.vm_configurations[count.index]["subnet_name"]
  virtual_network_name = data.azurerm_virtual_network.vnet[count.index].name
  resource_group_name  = data.azurerm_virtual_network.vnet[count.index].resource_group_name
}

resource "azurerm_network_interface" "vmnic" {
  count               = length(var.vm_configurations)
  name                = "${var.vm_configurations[count.index]["name"]}-nic"
  location            = data.azurerm_resource_group.vm_rg[count.index].location
  resource_group_name = data.azurerm_resource_group.vm_rg[count.index].name

  ip_configuration {
    name      = "ipconfig"
    subnet_id = data.azurerm_subnet.vmsubnet[count.index].id
    private_ip_address_allocation = "Static"     
    # private_ip_address_allocation = "Dynamic"
    private_ip_address            = var.vm_configurations[count.index].ip_address
  }
}

# data "azurerm_key_vault" "key_vault" {
#   name                = var.KeyVaultName
#   resource_group_name = var.kv_rg
# }

resource "tls_private_key" "ssh_algo" {
  count     = length(var.vm_configurations)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "github_repository_file" "foo" {
  count = length(var.vm_configurations)
  repository          = "https://github.com/aman-singh019/justfortest.git"
  branch              = "main"     #"feature/wink-dev-can-central-scr01"
  file                = "wink-dev-can-central-scr01-test-pem"
  content             = tls_private_key.ssh_algo[count.index].private_key_pem
  overwrite_on_create = true
}

# resource "local_file" "linux_key" {
#   count = length(var.vm_configurations)
#   filename = "./${var.vm_configurations[count.index]["name"]}-pem"
#   content  = tls_private_key.ssh_algo[count.index].private_key_pem
# }

resource "azurerm_linux_virtual_machine" "linuxvm" {
  count                 = length(var.vm_configurations)
  name                  = var.vm_configurations[count.index]["name"]
  location              = data.azurerm_resource_group.vm_rg[count.index].location
  resource_group_name   = data.azurerm_resource_group.vm_rg[count.index].name
  network_interface_ids = [azurerm_network_interface.vmnic[count.index].id]
  size                  = var.vm_configurations[count.index]["vm_Size"]

  source_image_reference {
    publisher = var.vmimage["publisher"]
    offer     = var.vmimage["offer"]
    sku       = var.vmimage["sku"]
    version   = var.vmimage["version"]
  }

  admin_ssh_key {
    username   = var.vmUserName
    public_key = tls_private_key.ssh_algo[count.index].public_key_openssh#azurerm_key_vault_secret.ssh_public_key[count.index].value
  }

  os_disk {
    name                 = "${var.vm_configurations[count.index]["name"]}-os"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type #generalise storage account type { Standard_LRS, StandardSSD_LRS, Premium_LRS,StandardSSD_ZRS and Premium_ZRS }
    disk_size_gb         = var.vm_configurations[count.index]["os_disk_size"]

  }
  #Encrypt the OS disk to enhance data security.
  #encryption_at_host_enabled=true 

  computer_name  = var.vm_configurations[count.index]["name"]
  admin_username = var.vmUserName
}

resource "azurerm_managed_disk" "datadisk" {
  #count = var.vm_configurations["data_disks_count"]==0?0:1
  for_each             = { for idx, datadisk in local.datadisk_objects : idx => datadisk }
  name                 = each.value.datadisk_name
  location             = each.value.location
  resource_group_name  = each.value.rg_name
  storage_account_type = var.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk_attach" {
  for_each           = { for idx, datadisk in local.datadisk_objects : idx => datadisk }
  managed_disk_id    = azurerm_managed_disk.datadisk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.linuxvm[each.value.vm_index].id
  lun                = each.value.lun
  caching            = "None"
}

