# outputs.tf

output "region" {
value         = var.region_list[0]
}
output "owner" {
value                            = var.owner
}
output "project_name" {
value                     =  var.project_name
}
