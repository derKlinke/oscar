#!/bin/sh

# configure aws cli
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION

# TODO: put oscar into its own bucket

# make nice DMG
rsync -a CI_DEVELOPER_ID_SIGNED_APP_PATH "ci_scripts/source_folder/"

create-dmg \
    --volname "Oscar Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --volicon "./resources/volicon.icns" \
    --icon-size 100 \
    --icon "Oscar.app" 200 190 \
    --hide-extension "Oscar.app" \
    --app-drop-link 600 185 \
    "oscar-installer.dmg" \
    "./ci_scripts/source_folder/"

# upload the build to s3
echo $CI_DEVELOPER_ID_SIGNED_APP_PATH
aws s3 cp "oscar-installer.dmg" s3://$AWS_S3_BUCKET/apps/oscar/oscar-$CI_BUILD_NUMBER.dmg

# do sparkle magic
