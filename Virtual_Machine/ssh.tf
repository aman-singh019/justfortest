
resource "tls_private_key" "ssh_algo" {
  count     = length(var.vm_configurations)
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  count        = length(var.vm_configurations)
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "${var.vm_configurations[count.index]["name"]}-pub"
  value        = tls_private_key.ssh_algo[count.index].public_key_openssh
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  count        = length(var.vm_configurations)
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "${var.vm_configurations[count.index]["name"]}-pem"
  value        = tls_private_key.ssh_algo[count.index].private_key_pem
}
