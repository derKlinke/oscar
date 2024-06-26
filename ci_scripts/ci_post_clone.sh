#!/bin/sh

# install additional dependencies
brew install awscli
brew install create-dmg

# only run script on pull requests
# auto close request and use the branch name as the version
# put version into plist, commit that change
# create a tag with the version
