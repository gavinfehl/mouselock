#!/bin/sh
set -e

# get version tag or commit id
VERSION=$(git describe --tags 2>/dev/null || echo "0.0.0-dev")

# set app version
agvtool new-version "${VERSION#v}"

# build
xcodebuild -quiet -configuration Release -target Mouselock

# clean dist
rm -rf dist && mkdir dist

# make dmg from app
hdiutil create -fs HFS+ -srcfolder build/Release/Mouselock.app -volname Mouselock dist/Mouselock.dmg

# clean build
rm -r build