/*
======
Create IAM User
======
*/
resource "aws_iam_user" "vault_ec2_user" {
  name = "vault-ec2-user"
  path = "/"
}

resource "aws_iam_access_key" "vault_ec2_user" {
  user = aws_iam_user.vault_ec2_user.name
}

data "aws_iam_policy_document" "vault_ec2_user" {
  statement {
    sid    = "VaultAWSAuthMethod"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:ListRoles",
      "iam:GetRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "vault_ec2_user" {
  name   = "vault-ec2-user-policy"
  user   = aws_iam_user.vault_ec2_user.name
  policy = data.aws_iam_policy_document.vault_ec2_user.json
}

/*
======
Create IAM Role for EC2 Service
======
*/
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "vault-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "vault-client" {
  name = "vault-ec2-role-instance-profile"
  role = aws_iam_role.ec2_role.id
}