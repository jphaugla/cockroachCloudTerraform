resource "local_file" "instances_file" {
    filename = "${var.instances_inventory_file}"
    content = templatefile("${path.module}/${var.inventory_template_file}",
        {
            app_public_ip = "${aws_instance.app.0.public_ip}"
            app_private_ip = "${aws_instance.app.0.private_ip}"
            app_private_ips = "${join("\n", aws_instance.app[*].private_ip)}"
            app_public_ips = "${join("\n", aws_instance.app[*].public_ip)}"
            app_public_ips_un = "${join("\n", [for ip in aws_instance.app.*.public_ip: "${ip} ansible_user=${local.admin_username}"])}"
            ssh_user = "${local.admin_username}"
            all_public_ips_un = "${join("\n", flatten([
              [for ip in aws_instance.app.*.public_ip: "${ip} ansible_user=${local.admin_username}"]
            ]))}"
            all_public_ips = "${join("\n", compact([
              join("\n", aws_instance.app.*.public_ip)
            ]))}"
        })

    depends_on = [
       aws_instance.app
    ]
}
