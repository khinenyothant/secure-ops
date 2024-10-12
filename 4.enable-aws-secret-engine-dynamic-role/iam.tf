resource "aws_iam_user" "vault_admin" {
  name = var.vault_admin_iam_user
  path = "/"

  tags = {
    tag-key = var.vault_admin_iam_user
  }
}

resource "aws_iam_access_key" "vault_admin" {
  user = aws_iam_user.vault_admin.name
}

data "aws_iam_policy_document" "vault_admin" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachUserPolicy",
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:DeleteUser",
      "iam:DeleteAccessKey",
      "iam:DeleteUserPolicy",
      "iam:DetachUserPolicy",
      "iam:GetUser",
      "iam:ListAccessKeys",
      "iam:ListAttachedUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserPolicies",
      "iam:PutUserPolicy",
      "iam:AddUserToGroup",
      "iam:RemoveUserFromGroup"
    ]
    resources = [
      "arn:aws:iam::038462783240:user/vault-*"
    ]
  }
}

resource "aws_iam_user_policy" "vault_admin" {
  name   = var.vault_admin_policy_name
  user   = aws_iam_user.vault_admin.name
  policy = data.aws_iam_policy_document.vault_admin.json
}