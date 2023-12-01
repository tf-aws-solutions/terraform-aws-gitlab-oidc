data "tls_certificate" "gitlab" {
  url = var.gitlab_tls_url
}

resource "aws_iam_openid_connect_provider" "gitlab" {
  url             = var.gitlab_url
  client_id_list  = [var.oidc_audience]
  thumbprint_list = [data.tls_certificate.gitlab.certificates[0].sha1_fingerprint]

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }

    condition {
      test     = "StringLike"
      variable = "${aws_iam_openid_connect_provider.gitlab.url}:sub"
      values   = var.repositories
    }
  }
}

resource "aws_iam_role" "gitlab" {
  name                 = "${var.prefix}-gitlab-cicd"
  description          = "AWS role dedicated for Gitlab CI/CD to deploy infrastructure defined in Terraform"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  max_session_duration = var.max_session_duration

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "gitlab" {
  for_each = toset(var.iam_policies)

  role       = aws_iam_role.gitlab.name
  policy_arn = each.key
}
