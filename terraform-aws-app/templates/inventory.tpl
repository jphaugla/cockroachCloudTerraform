[kafka_node_ips]
${kafka_public_ip} ansible_user=ubuntu
[app_node_ips]
${app_public_ips_un} 
[all_public_node_ips]
${all_public_ips_un}
[all:vars]
ansible_connection=ssh
