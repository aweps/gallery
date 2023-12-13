#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

flutter clean || :

# Clean fastlane files
(cd ios && fastlane run clean_cocoapods_cache) || :
(cd ios && fastlane run xcclean scheme:Runner) || :
(cd ios && fastlane run clean_build_artifacts) || :
(cd android && fastlane run clean_build_artifacts) || :

rm -rf .cicd
rm -rf build
rm -rf _ops/keystore.jks
rm -rf ios/fastlane/report.xml
rm -rf android/.gradle
rm -rf ios/App.*
rm -rf ios/Runner.xcarchive
rm -rf ios/Pods
rm -rf ~/Library/Developer/Xcode/DerivedData/* || :
rm -rf $PUB_CACHE/*
rm -rf $GRADLE_CACHE/*
#rm -rf $FLUTTER_HOME/*

# This removes all untracked files including secrets
#git clean -fdx
