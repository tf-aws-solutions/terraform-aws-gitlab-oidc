# AWS OIDC provider for Gitlab

## Introduction

Gitlab has a very good support for Terraform:
- HTTP endpoint for Terraform [state](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html)
- Dedicated images for Terraform deployment plus high and low level CI/CD [templates](https://docs.gitlab.com/ee/user/infrastructure/iac/) using these images
- Terraform specific environment [variables](https://docs.gitlab.com/ee/user/infrastructure/iac/gitlab_terraform_helpers.html#generic-variables)

To deploy infrastructure to AWS using Terraform, one is usally tempted to use AWS access key and secret stored in Gitlab as CI/CD variables and exposed to Terraform runner as environment variables.
But this is not the best practice in terms of security and usability. Gitlab makes it easier by allowing to be configured in AWS as OIDC provider which allows using AWS temporary credentials. 
JWT token generated by Gitlab for project/pipeline/branch/job is [exchanged](https://docs.gitlab.com/ee/ci/cloud_services/#authorization-workflow) for AWS temporary credentials that allow to assume a dedicated role for a time limited session.

## Description

This module deploys AWS resources necessary to exchange Gitlab JWT token for AWS credentials:
- OIDC identity provider
- IAM role with proper trust policy and access policies attached

JWT token is verified both at the level of OIDC provider - where JWT aud is checked - and at the level of trust policy by a condition that checks JWT sub. This is why it is important to specify Gitlab projects/reposiotories that should have access to AWS.
These should be configured using input variable `repositories`

For repositories list, each item should have a format of `project_path:YOUR_PROJECT-GROUP/YOUR-PROJECT:ref_type:branch:ref:BRANCH-NAME` or `project_path:YOUR_PROJECT-GROUP/YOUR-PROJECT:ref_type:tag:ref:TAG` depending on whether the pipeline was executed for a branch or a tag.

Wildcards are supported - follow these [examples](https://docs.gitlab.com/ee/ci/cloud_services/#configure-a-conditional-role-with-oidc-claims)

## Usage

This module prepares AWS and Gitlab integration so it should be deployed first, before the deployment of the target infrastructure as a code, and should be best kept in its own state file. 
To deploy the module, Terraform AWS provider needs to be supplied with AWS credentials, e.g. access key and secret or profile, to the account where the module needs to be deployed. 
After deployment, these temporary credentials can be removed and now the OIDC provider will be issuing AWS credentials needed for deployment of the subsequent infrastructure.

The output of the module is ARN of a role that will be used in Gitlab CI/CD pipeline, so it should be copied to Gitlab CI/CD variable, for example `GITLAB_ROLE_ARN`

To obtain temporary AWS credentials, each job that should have access to AWS, for example the one that executes `terraform plan` or `terraform apply` should have the following `before_script`:

```
  id_tokens:
    OIDC_TOKEN:
      aud: https://gitlab.com  //Or your Gitlab server address
  before_script:
    - echo "${OIDC_TOKEN}" > /tmp/web_identity_token
    - export AWS_ROLE_ARN="${GITLAB_ROLE_ARN}"
    - export AWS_WEB_IDENTITY_TOKEN_FILE="/tmp/web_identity_token"
    - export AWS_ROLE_SESSION_NAME="GitlabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
```
According to this configuration [method](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-oidc) and how Terraform AWS provider reads [credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#assume-role-with-web-identity-configuration-reference)

