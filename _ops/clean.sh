#!/bin/bash

set -Eeuo pipefail
if [ "$(echo "${DEBUG:-}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then set -x; fi

# Load ENV
source _ops/utils/env.sh

# Check if this script is running on Linux 
if [[ "$OSTYPE" != "darwin"* ]]; then
	# Check if not running under docker
	if [[ "${USE_DOCKER:-}" != "true" ]]; then
		echo "Need to run under docker under linux. set USE_DOCKER"
		exit 1
	fi
fi

flutter clean || :

# Clean fastlane files
(cd ios && fastlane run clean_cocoapods_cache) || :
(cd ios && fastlane run xcclean scheme:Runner) || :
(cd ios && fastlane run clean_build_artifacts) || :
(cd android && fastlane run clean_build_artifacts) || :

rm -rf .cicd
rm -rf build
rm -rf _ops/keystore.jks
rm -rf android/.gradle
rm -rf ios/App.*
rm -rf ios/Runner.xcarchive
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/* || :
rm -rf $PUB_CACHE/*
rm -rf $GRADLE_CACHE/*
rm -rf $FLUTTER_HOME/success
#rm -rf $FLUTTER_HOME/*

# This removes all untracked files including secrets
#git clean -fdx
