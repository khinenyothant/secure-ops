output "aws_access_key" {
  description = "Dynamic Role iam user access key"
  value       = data.vault_aws_access_credentials.creds.access_key
  sensitive   = true
}

output "aws_secret_key" {
  description = "Dynamic Role iam user secret key"
  value       = data.vault_aws_access_credentials.creds.secret_key
  sensitive   = true
}