resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.rg_name
  location            = var.loc_name
  size                = "Standard_E2s_v3"

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [var.nic_id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # ✅ Copy script to VM
  provisioner "file" {
    source      = "${path.module}/script.sh"
    destination = "/home/${var.admin_username}/script.sh"

    connection {
      type     = "ssh"
      host     = var.public_ip
      user     = var.admin_username
      password = var.admin_password
      port     = 22
    }
  }

  # ✅ Execute script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/script.sh",
      "sudo /home/${var.admin_username}/script.sh"
    ]

    connection {
      type     = "ssh"
      host     = var.public_ip
      user     = var.admin_username
      password = var.admin_password
      port     = 22
    }
  }
}