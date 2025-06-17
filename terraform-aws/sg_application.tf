module "sg_application" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "${var.owner}-${var.project_name}-sg-application"
  description = "Allow HTTP (8080, 8000) and App(3000) from trusted IPs"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  ingress_cidr_blocks = concat(var.netskope_ips, ["${var.my_ip_address}/32"])

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow HTTP on 8080 from trusted IPs"
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "Allow HTTP on 8000 from trusted IPs"
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Allow application port 3000 from trusted IPs"
    },
  ]
# NEW: allow CockroachDB PrivateLink (port 26257) from any host in this SG
  ingress_with_source_security_group_id = [
    {
      from_port                = 26257
      to_port                  = 26257
      protocol                 = "tcp"
      source_security_group_id = module.sg_application.security_group_id
      description              = "Allow CRDB SQL (26257) from app hosts"
    }
  ]

  egress_rules = ["all-all"]
}
