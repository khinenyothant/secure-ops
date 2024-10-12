#Create a KV Secrets Engine
#vault secrets enable -path=example -version=2 kv
resource "vault_mount" "kvv2" {
  path        = var.secret_engine_path
  type        = var.secret_engine_type
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

#Store a Secret in the KV Engine
#vault kv put example/unsecret \ ...
resource "vault_kv_secret_v2" "example" {
  mount               = vault_mount.kvv2.path
  name                = "unsecret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      foo                         = "bar",
      dynamic_provider_credential = "true",
      add_new_key_value           = "add_new"
    }
  )
}