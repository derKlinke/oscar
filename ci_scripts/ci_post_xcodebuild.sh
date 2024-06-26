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
LOCAL_BUCKET=./local_bucket

# make nice DMG
rsync -a $APP_PATH $SRC_FOLDER
if [ ! -d "$SRC_FOLDER/Oscar.app" ]; then
    echo "Oscar.app not found in $SRC_FOLDER"
    exit 1
fi

create-dmg \
    --volname "Oscar Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --volicon "volicon.icns" \
    --icon-size 100 \
    --icon "Oscar.app" 200 190 \
    --hide-extension "Oscar.app" \
    --app-drop-link 600 185 \
    --sandbox-safe \
    "oscar-installer.dmg" \
    "$SRC_FOLDER"
    
if [ ! -f "oscar-installer.dmg" ]; then
    echo "oscar-installer.dmg not found"
    exit 1
fi

# upload the build to s3
aws s3 cp "oscar-installer.dmg" $AWS_S3_BUCKET/oscar-$APP_VERSION.dmg


# do sparkle magic
aws s3 cp --recursive $AWS_S3_BUCKET $LOCAL_BUCKET
echo $SPARKLE_PRIVATE_KEY
echo $SPARKLE_PRIVATE_KEY | bin/generate_appcast $LOCAL_BUCKET
aws s3 cp $LOCAL_BUCKET/appcast.xml $AWS_S3_BUCKET/appcast.xml
