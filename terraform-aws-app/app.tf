# Only one app-instance, or none
resource "aws_instance" "app" {
  count                       = var.include_app == "yes" ? 1 : 0

  ami                         = data.aws_ami.amazon_linux_2023_x64.id
  instance_type               = var.app_instance_type
  key_name                    = var.instance_key_name

  tags = merge(
    local.tags,
    { Name = "${var.owner}-crdb-app" }
  )
  # attach the instance profile only if we created it
  iam_instance_profile = var.create_iam_resources && length(aws_iam_instance_profile.ec2_instance_profile) > 0 ? aws_iam_instance_profile.ec2_instance_profile[0].name : null

  primary_network_interface {
    # will resolve to aws_network_interface.app[0].id when count = 1
    network_interface_id = aws_network_interface.app[count.index].id
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 100
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
}

resource "local_file" "cluster_cert" {
  filename = "${var.playbook_working_directory}/temp/${var.aws_region}/tls_cert"
  content  = var.crdb_cluster_cert
}
