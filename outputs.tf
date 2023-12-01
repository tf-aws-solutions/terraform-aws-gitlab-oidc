output "gitlab_role_arn" {
  value       = aws_iam_role.gitlab.arn
  description = "This role ARN should be put into Gitlab CI/CD variable (e.g. GITLAB_ROLE_ARN) to be used in Terraform pipeline for generating temporary AWS credentials."
}