#!/bin/sh

# configure aws cli
brew install awscli
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION

# upload the build to s3
echo $CI_DEVELOPER_ID_SIGNED_APP_PATH
aws s3 cp $CI_DEVELOPER_ID_SIGNED_APP_PATH s3://$AWS_S3_BUCKET/apps/oscar/oscar-$CI_BUILD_NUMBER.app
