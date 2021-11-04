# docker-ecr-ap-base-image

[![CircleCI](https://circleci.com/gh/dwp/docker-ecr-ap-base-image.svg?style=svg)](https://circleci.com/gh/dwp/docker-ecr-ap-base-image) [![Known Vulnerabilities](https://snyk.io/test/github/dwp/docker-ecr-ap-base-image/badge.svg)](https://snyk.io/test/github/dwp/docker-ecr-ap-base-image)

## Repo for the docker base image used for AP

This is a repo for creating docker base images for AP in dataworks. The flow starts from a concourse pipeline and then triggers into GHA workflow to build docker images then pushes the image into a private ECR repository.
This repo contains Makefile, Dockerfile and base terraform folders and jinja2 files to fit the standard pattern.
This repo is a base to create new Docker building repos, adding the githooks submodule, making the repo ready for use.

Running aviator will create the pipeline required on the AWS-Concourse instance, in order pass a mandatory CI ran status check.  this will likely require you to login to Concourse, if you haven't already.

For more information please go to:
https://git.ucd.gpn.gov.uk/dip/datsci-model-build/wiki

## Environment Variables
This jupyterhub image requires the following environment variables at runtime:

| Env var | Description | Example value | Required |
| ------- | ----------- | ------------- | -------- |
| USER    | User to run jupyterhub as | steve | true |
| KMS_HOME    | ARN for users home KMS Key | arn:xxx: | true |
| KMS_SHARED    | ARN for shared KMS Key | arn:xxx: | true |
| LIVY_SESSION_STARTUP_TIMEOUT_SECONDS | Sparkmagic config to set the timeout for the Livy session startup | 120 | false |

The following environment variables can be used to configure Cognito authentication. 

| Env var | Description | Example value |
| ------- | ----------- | ------------- |
| COGNITO_ENABLED    | Enable Cognito Auth | true |
| COGNITO_CLIENT_ID  | Cognito Client ID | exampleid |
| COGNITO_CLIENT_SECRET | Cognito Client Secret | examplesecret |
| COGNITO_OAUTH_CALLBACK_URL | Callback url for successful login | `http://localhost:3000`|
| COGNITO_OAUTH_LOGOUT_CALLBACK_URL | Callback url for logout | `http://example.com`

If Cognito Authentication is enabled, home directories for the Cognito users need to be created manually

After cloning this repo, please run:  
`make bootstrap`

In addition, you may want to do the following: 

1. Create non-default Terraform workspaces as and if required:  
    `make terraform-workspace-new workspace=<workspace_name>` e.g.  
    ```make terraform-workspace-new workspace=qa```

1. Configure Concourse CI pipeline:
    1. Add/remove jobs in `./ci/jobs` as required 
    1. Create CI pipeline:  
`aviator`