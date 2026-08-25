#!/bin/sh
set -e

# set app version
agvtool new-version 1.0.0

# build
xcodebuild -quiet -configuration Release -target Mouselock

# clean dist
rm -rf dist && mkdir dist

# make dmg from app
hdiutil create -fs HFS+ -srcfolder build/Release/Mouselock.app -volname Mouselock dist/Mouselock.dmg

# clean build
rm -r build