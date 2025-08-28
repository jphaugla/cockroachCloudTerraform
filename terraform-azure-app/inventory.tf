resource "local_file" "instances_file" {
    filename = "${var.instances_inventory_file}"
    content = templatefile("${path.module}/${var.inventory_template_file}",
        {
            app_public_ip = "${azurerm_linux_virtual_machine.app.0.public_ip_address}"
            app_private_ip = "${azurerm_linux_virtual_machine.app.0.private_ip_address}"
            app_private_ips = "${join("\n", azurerm_linux_virtual_machine.app[*].private_ip_address)}"
            app_public_ips = "${join("\n", azurerm_linux_virtual_machine.app[*].public_ip_address)}"
            all_private_ips = "${join("\n", azurerm_linux_virtual_machine.app[*].private_ip_address)}"
            all_public_ips = "${join("\n", azurerm_linux_virtual_machine.app[*].public_ip_address)}"
            kafka_public_ip = length(azurerm_linux_virtual_machine.kafka) > 0 ? "${azurerm_linux_virtual_machine.kafka.0.public_ip_address}" : "null"
            kafka_private_ip = length(azurerm_linux_virtual_machine.kafka) > 0 ? "${azurerm_linux_virtual_machine.kafka.0.private_ip_address}" : "null"
            ssh_user = "${var.login_username}"
        })

    depends_on = [
         azurerm_public_ip.app-ip
    ]
}
