resource "local_file" "cluster_cert" {
  filename = "${var.playbook_working_directory}/temp/${var.virtual_network_location}/tls_cert"
  content  = var.crdb_cluster_cert
}
