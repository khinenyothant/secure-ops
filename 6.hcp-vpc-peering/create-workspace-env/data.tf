data "tfe_workspace" "my_workspace" {
  name         = var.workspace_name
  organization = var.org_name
}