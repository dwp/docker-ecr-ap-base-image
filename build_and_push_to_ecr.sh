#!/bin/bash

set -euo pipefail

# Build the image
docker build -t "$IMAGE_NAME" .

# Dev First
DEV_REG_URL="${DEV_AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
AWS_ACCESS_KEY_ID="$DEV_AWS_ACCESS_KEY_ID" \
AWS_SECRET_ACCESS_KEY="$DEV_AWS_SECRET_ACCESS_KEY" \
AWS_SESSION_TOKEN="$DEV_AWS_SESSION_TOKEN" \
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$DEV_REG_URL"

for TAG in "latest" "$SEM_VER" ; do 
  docker tag "$IMAGE_NAME" "$DEV_REG_URL/$IMAGE_NAME:$TAG"
  docker push "$DEV_REG_URL/$IMAGE_NAME:$TAG" | sed "s/$DEV_AWS_ACCOUNT/XXXXXXXX/"
done

# Live Second
REG_URL="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$REG_URL"

for TAG in "latest" "$SEM_VER" ; do
  docker tag "$IMAGE_NAME" "$REG_URL/$IMAGE_NAME:$TAG"
  docker push "$REG_URL/$IMAGE_NAME:$TAG" | sed "s/$AWS_ACCOUNT/XXXXXXXX/"
done

# Complete
exit 0
