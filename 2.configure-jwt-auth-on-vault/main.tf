#Enable the JWT auth method & Configure JWT settings
#vault auth enable jwt & vault write auth/jwt/config \...
resource "vault_jwt_auth_backend" "jwt" {
  description        = "Demonstration of the Terraform JWT auth backend"
  path               = var.path
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

#Create policy
#vault policy write <policy_name> -<<EOT...
resource "vault_policy" "vault_admin_policy" {
  name = var.policy_name

  policy = <<EOT
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Enable and manage the key/value secrets engine at `secret/` path
# List, create, update, and delete key/value secrets
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts"
{
  capabilities = ["read"]
}

path "sys/policy/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/policy/" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/policies/" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "aws-master-account/" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "aws-master-account/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "aws-master-vault-admin/" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "aws-master-vault-admin/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/mounts/kvv2" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "kvv2/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

#Create role with policy
#vault write auth/jwt/role/<role_name> \...
resource "vault_jwt_auth_backend_role" "admin_role" {
  backend           = vault_jwt_auth_backend.jwt.path
  role_name         = var.role_name
  token_policies    = [vault_policy.vault_admin_policy.name]
  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:hellocloud-knt:project:SecureOps:workspace:*:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = var.role_type
  token_ttl  = 1200
}