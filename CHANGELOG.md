# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2023-12-01

### Added

- OIDC provider for Gitlab with defaults for gitlab.com
- Multiple Gitlab projects/repositories can be authorized.
- AWS role to be assumed with user assigned IAM policies.
- Usage instructions based on Gitlab id_tokens introduced in v15.7 as CI_JOB_JWT_V2 has been deprecated since v15.9 (https://docs.gitlab.com/ee/update/deprecations.html#old-versions-of-json-web-tokens-are-deprecated)
