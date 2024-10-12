variable "workspace_name" {
  description = "Workspace Name"
  type        = string
  default     = "4_enable-aws-secret-engine-dynamic-role"
}
variable "org_name" {
  description = "Organization Name"
  type        = string
  default     = "hellocloud-knt"
}
variable "vault_url" {
  description = "The address of the Vault instance runs will access."
  type        = string
  default     = "https://vault-cluster-public-vault-d956a58b.a68d84be.z1.hashicorp.cloud:8200" ### have to change new vault cluster id
}
variable "run_role" {
  description = "TFC_VAULT_RUN_ROLE"
  type        = string
  default     = "admin-role"
}
variable "vault_namespace" {
  description = "TFC_VAULT_NAMESPACE"
  type        = string
  default     = "admin"
}
variable "aws_region" {
  description = "AWS_REGION"
  type        = string
  default     = "ap-northeast-1"
}