output "role-name" {
  description = "Vault backend JWT role name"
  value       = vault_jwt_auth_backend_role.admin_role.role_name
}

output "openid_claim" {
  description = "Vault backend JWT role validates the incoming token's subject."
  value       = vault_jwt_auth_backend_role.admin_role.bound_claims
}