#Retrieve AWS Access Dynamic Credentials
#vault read aws/creds/<role_name>
data "vault_aws_access_credentials" "creds" {
  depends_on = [time_sleep.wait_before_fetching_creds]
  backend    = vault_aws_secret_backend.aws.path
  role       = vault_aws_secret_backend_role.role.name
}