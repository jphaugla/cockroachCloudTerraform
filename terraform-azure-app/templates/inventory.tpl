[app_node_ips]
${app_public_ips}
[all_public_node_ips]
${all_public_ips}
[all:vars]
ansible_connection=ssh
ansible_user=${ssh_user}
