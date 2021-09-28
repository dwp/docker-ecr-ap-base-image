#!/bin/sh

set -euo pipefail

#No debug printing!
set +x

DURATION="${ASSUME_DURATION:=1800}"

# Generate Dev Management Credentials
DEV_MGMT_ACCOUNT="$(jq -r '."management-dev"' < accounts.json)"
ROLE_ARN="arn:aws:iam::$DEV_MGMT_ACCOUNT:role/gha_ecr"
AWS_STS="$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "dev-ci-$(date +%m%d%y%H%M%S)" --duration-seconds ${DURATION})"

DEV_SECRET_ACCESS_KEY="$(echo "$AWS_STS" | jq '.Credentials.SecretAccessKey' -r)"
DEV_ACCESS_KEY_ID="$(echo "$AWS_STS" | jq '.Credentials.AccessKeyId' -r)"
DEV_SESSION_TOKEN="$(echo "$AWS_STS" | jq '.Credentials.SessionToken' -r)"

## Generate Live Management Credentials
MGMT_ACCOUNT="$(jq -r '.management' < accounts.json)"
ROLE_ARN="arn:aws:iam::$MGMT_ACCOUNT:role/gha_ecr"
AWS_STS="$(aws sts assume-role --role-arn "$ROLE_ARN" --role-session-name "ci-$(date +%m%d%y%H%M%S)" --duration-seconds ${DURATION})"

SECRET_ACCESS_KEY="$(echo "$AWS_STS" | jq '.Credentials.SecretAccessKey' -r)"
ACCESS_KEY_ID="$(echo "$AWS_STS" | jq '.Credentials.AccessKeyId' -r)"
SESSION_TOKEN="$(echo "$AWS_STS" | jq '.Credentials.SessionToken' -r)"

# Write Credentials to Output
cat > gha_ecr_sts_creds <<EOT
export TF_VAR_gha_dev_ecr="{
  access_key_id=\"$DEV_ACCESS_KEY_ID\"
  secret_access_key=\"$DEV_SECRET_ACCESS_KEY\"
  session_token=\"$DEV_SESSION_TOKEN\"
  account=\"$DEV_MGMT_ACCOUNT\"
}"

export TF_VAR_gha_ecr="{
  access_key_id=\"$ACCESS_KEY_ID\"
  secret_access_key=\"$SECRET_ACCESS_KEY\"
  session_token=\"$SESSION_TOKEN\"
  account=\"$MGMT_ACCOUNT\"
}"
EOT
