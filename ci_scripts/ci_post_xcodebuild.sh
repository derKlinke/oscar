#!/bin/sh

APP_PATH="${CI_DEVELOPER_ID_SIGNED_APP_PATH}/Oscar.app"
INFO_PLIST_PATH="${APP_PATH}/Contents/Info.plist"
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST_PATH")

echo "APP_PATH: $APP_PATH"
echo "INFO_PLIST_PATH: $INFO_PLIST_PATH"
echo "APP_VERSION: $APP_VERSION"

# configure aws cli
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
aws configure set default.region $AWS_DEFAULT_REGION

# TODO: put oscar into its own bucket

SRC_FOLDER=./scr_folder

# make nice DMG
rsync -a $APP_PATH $SRC_FOLDER

create-dmg \
    --volname "Oscar Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --volicon "volicon.icns" \
    --icon-size 100 \
    --icon "Oscar.app" 200 190 \
    --hide-extension "Oscar.app" \
    --app-drop-link 600 185 \
    "oscar-installer.dmg" \
    "$SRC_FOLDER"

# upload the build to s3
aws s3 cp "oscar-installer.dmg" $AWS_S3_BUCKET/oscar-$APP_VERSION.dmg

# do sparkle magic
