#enable AWS authentication in Vault
#vault auth enable aws
resource "vault_auth_backend" "aws" {
  type = "aws"
}

#create an AWS IAM client in Vault by using authenticate vault_ec2_user iam credentials
#vault write auth/aws/login \...
resource "vault_aws_auth_backend_client" "aws" {
  backend    = vault_auth_backend.aws.path
  access_key = aws_iam_access_key.vault_ec2_user.id
  secret_key = aws_iam_access_key.vault_ec2_user.secret
}

#Create policy
#vault policy write <policy_name> -<<EOT...
resource "vault_policy" "db-policy" {
  name   = "db-policy"
  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}
# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}
path "db/" {
  capabilities = ["read","list"]
}
path "db/*" {
  capabilities = ["read","list"]
}
path "aws-master-account/" {
  capabilities = ["read","list"]
}
path "aws-master-account/*" {
  capabilities = ["read","list"]
}
EOT
}

resource "time_sleep" "wait_before_creating_role" {
  depends_on      = [aws_iam_role.ec2_role]
  create_duration = "20s"
}

#Create role with policy
#vault write auth/aws/role/db-role \...
resource "vault_aws_auth_backend_role" "aws" {
  depends_on               = [time_sleep.wait_before_creating_role]
  backend                  = vault_auth_backend.aws.path
  role                     = "db-role"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.ec2_role.arn]
  token_ttl                = 300
  token_max_ttl            = 600
  token_policies           = [vault_policy.db-policy.name]
}