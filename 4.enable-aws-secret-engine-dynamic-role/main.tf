#enable the AWS secrets backend & configure the backend with the access and secret keys
#vault secrets enable -path=<var.aws_secret_engine_path> aws
#vault write aws/config \...
resource "vault_aws_secret_backend" "aws" {
  access_key                = aws_iam_access_key.vault_admin.id
  secret_key                = aws_iam_access_key.vault_admin.secret
  region                    = var.region
  path                      = var.aws_secret_engine_path
  default_lease_ttl_seconds = 900
  max_lease_ttl_seconds     = 1500
}

#Create a Role for the AWS Secrets Backend
#vault write aws/roles/...
resource "vault_aws_secret_backend_role" "role" {
  backend         = vault_aws_secret_backend.aws.path
  name            = var.vault_aws_secret_backend_role_name
  credential_type = var.vault_aws_secret_backend_role_type
  policy_arns     = [var.vault_aws_secret_backend_role_policy_arn]
}

resource "time_sleep" "wait_before_fetching_creds" {
  depends_on      = [vault_aws_secret_backend_role.role]
  create_duration = "10s"
}
