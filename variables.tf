
variable "prefix" {
  type        = string
  description = "Prefix to be added in AWS resource names, e.g. projX-dev"
}

variable "gitlab_url" {
  type        = string
  description = "Gitlab URL for which to create OIDC provider in AWS."
  default     = "https://gitlab.com"
}

variable "oidc_audience" {
  type        = string
  description = "Client ID (audience) that identifies the application that is registered with an OpenID Connect provider. Should be the same as Gitlab URL."
  default     = "https://gitlab.com"
}

variable "gitlab_tls_url" {
  type        = string
  description = "Gitlab TLS URL from which to obtain certificate thumbprint."
  default     = "tls://gitlab.com:443"
}

variable "repositories" {
  type        = list(string)
  description = "List of Gitlab projects/repositories which should be able to assume AWS role. Use the format (can include wildcards): project_path:{group}/{project}:ref_type:{type}:ref:{branch_name} See https://docs.gitlab.com/ee/ci/cloud_services/#configure-a-conditional-role-with-oidc-claims"
}

variable "iam_policies" {
  type        = list(string)
  description = "List of IAM policy ARNs to be attached to Gitlab role."
}

variable "max_session_duration" {
  type        = number
  description = "Maximum session duration (in seconds) to set for the Gitlab role"
  default     = 3600
}

variable "tags" {
  description = "Tags and its values to be attached to AWS resources"
  type        = map(string)
  default     = {}
}